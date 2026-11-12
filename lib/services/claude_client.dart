import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Where chat requests are sent, and with what credentials.
///
/// Two modes, both chosen at build time so nothing secret is ever committed:
///
///  * **Proxy** — the app posts to a small server you control, which holds the
///    Anthropic key and forwards to the Messages API. The key never ships in
///    the binary. This is the only safe option for a released build.
///
///    `flutter build apk --dart-define=COACH_PROXY_URL=https://your-host/chat`
///
///  * **Direct** — the app calls api.anthropic.com itself with a key baked in.
///    Convenient while developing, but an APK is a zip: anyone who downloads it
///    can extract the key and spend against your account. Never ship this.
///
///    `flutter run --dart-define=ANTHROPIC_API_KEY=sk-ant-...`
///
/// With neither defined [isConfigured] is false, and the coach falls back to
/// the offline responses in AiService.
class ClaudeConfig {
  const ClaudeConfig._();

  static const proxyUrl = String.fromEnvironment('COACH_PROXY_URL');
  static const apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');

  /// Overridable so you can drop to a cheaper model without touching code:
  /// `--dart-define=COACH_MODEL=claude-sonnet-5`
  static const model =
      String.fromEnvironment('COACH_MODEL', defaultValue: 'claude-opus-5');

  static bool get usingProxy => proxyUrl.isNotEmpty;
  static bool get isConfigured => proxyUrl.isNotEmpty || apiKey.isNotEmpty;

  static Uri get endpoint => Uri.parse(
      usingProxy ? proxyUrl : 'https://api.anthropic.com/v1/messages');
}

/// A failure worth showing the user, kept separate from the raw HTTP detail so
/// the chat screen can tell "retrying might work" from "this needs fixing".
class ClaudeException implements Exception {
  ClaudeException(this.message, {this.retryable = false, this.statusCode});

  final String message;
  final bool retryable;
  final int? statusCode;

  @override
  String toString() => 'ClaudeException($statusCode): $message';
}

/// Minimal streaming client for the Messages API.
///
/// Dart has no official Anthropic SDK, so this speaks the REST endpoint
/// directly and parses the SSE stream by hand.
class ClaudeClient {
  ClaudeClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  void close() => _http.close();

  /// Streams the assistant's reply as it is generated, yielding text deltas.
  ///
  /// [history] is the prior turns, oldest first, already trimmed by the caller.
  Stream<String> streamReply({
    required String system,
    required List<Map<String, String>> history,
    int maxTokens = 1024,
    Duration timeout = const Duration(seconds: 60),
  }) async* {
    final request = http.Request('POST', ClaudeConfig.endpoint)
      ..headers.addAll(_headers())
      ..body =
          jsonEncode(_body(system: system, history: history, maxTokens: maxTokens));

    final http.StreamedResponse response;
    try {
      response = await _http.send(request).timeout(timeout);
    } on TimeoutException {
      throw ClaudeException('That took too long. Try again.', retryable: true);
    } catch (_) {
      // DNS failure, no connectivity, TLS problem — indistinguishable here, and
      // all the same thing to the user.
      throw ClaudeException('No connection.', retryable: true);
    }

    if (response.statusCode != 200) {
      throw _errorFor(response.statusCode, await response.stream.bytesToString());
    }

    // A refusal arrives as a normal 200 with stop_reason on the message_delta
    // event: the safety classifier declined rather than the request failing.
    String? stopReason;
    var sawText = false;

    final lines =
        response.stream.transform(utf8.decoder).transform(const LineSplitter());

    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload.isEmpty || payload == '[DONE]') continue;

      final Map<String, dynamic> event;
      try {
        event = jsonDecode(payload) as Map<String, dynamic>;
      } catch (_) {
        continue; // Keep-alive or partial frame; nothing to do with it.
      }

      switch (event['type']) {
        case 'content_block_delta':
          final delta = event['delta'] as Map<String, dynamic>?;
          // Only text_delta. Thinking blocks stream with empty text and would
          // otherwise surface as blank output.
          if (delta?['type'] == 'text_delta') {
            final text = delta?['text'] as String? ?? '';
            if (text.isNotEmpty) {
              sawText = true;
              yield text;
            }
          }
        case 'message_delta':
          final delta = event['delta'] as Map<String, dynamic>?;
          stopReason = delta?['stop_reason'] as String? ?? stopReason;
        case 'error':
          final err = event['error'] as Map<String, dynamic>?;
          throw ClaudeException(
            err?['message'] as String? ?? 'The coach stopped unexpectedly.',
            retryable: true,
          );
      }
    }

    if (stopReason == 'refusal') {
      // The fallback model declined as well, or this turn would have been
      // served by it. The caller substitutes an offline response.
      throw ClaudeException("I can't respond to that one.", statusCode: 200);
    }

    if (!sawText) {
      throw ClaudeException('Empty response from the coach.', retryable: true);
    }
  }

  Map<String, String> _headers() => {
        'content-type': 'application/json',
        if (!ClaudeConfig.usingProxy) ...{
          'x-api-key': ClaudeConfig.apiKey,
          'anthropic-version': '2023-06-01',
          // Lets the server retry on another model when a classifier declines,
          // instead of the turn just stopping. Worth having in an app where
          // people write about being at their lowest.
          'anthropic-beta': 'server-side-fallback-2026-07-01',
        },
      };

  Map<String, dynamic> _body({
    required String system,
    required List<Map<String, String>> history,
    required int maxTokens,
  }) =>
      {
        'model': ClaudeConfig.model,
        'max_tokens': maxTokens,
        'stream': true,
        'system': system,
        'messages': history,
        // Replies are a short paragraph of encouragement, so low effort keeps
        // the first token fast — which matters more than depth in a chat UI.
        'output_config': {'effort': 'low'},
        if (!ClaudeConfig.usingProxy) 'fallbacks': 'default',
      };

  ClaudeException _errorFor(int status, String rawBody) {
    String? apiMessage;
    try {
      final decoded = jsonDecode(rawBody) as Map<String, dynamic>;
      apiMessage =
          (decoded['error'] as Map<String, dynamic>?)?['message'] as String?;
    } catch (_) {
      // Non-JSON body (a proxy's HTML error page, say) — fall through to the
      // status-based message below.
    }

    return switch (status) {
      401 || 403 => ClaudeException(
          'The coach is not set up correctly (bad API key).',
          statusCode: status),
      402 => ClaudeException('The coach account needs billing attention.',
          statusCode: status),
      429 => ClaudeException('Too many messages right now. Give it a moment.',
          retryable: true, statusCode: status),
      >= 500 => ClaudeException('The coach is having a moment. Try again.',
          retryable: true, statusCode: status),
      _ => ClaudeException(apiMessage ?? 'Request failed ($status).',
          statusCode: status),
    };
  }
}
