import 'package:flutter_test/flutter_test.dart';
import 'package:motivate_me/services/ai_service.dart';

void main() {
  group('offline coach', () {
    test('crisis messages get support, not hype', () {
      for (final msg in [
        'I want to give up on life, I want to die',
        'I keep thinking about suicide',
        'my partner hits me',
      ]) {
        final r = AiService.instance.respond(msg);
        expect(r.text, contains('crisis line'), reason: msg);
      }
    });

    test('ordinary messages still get motivation', () {
      final r = AiService.instance.respond('I feel tired');
      expect(r.text, isNot(contains('crisis line')));
    });
  });
}
