# AI coach setup

The chat screen (`lib/screens/ai_chat_screen.dart`) talks to Claude through
`lib/services/claude_client.dart`. Both the endpoint and the credentials come
from `--dart-define` at build time, so nothing secret is ever committed.

## Three modes

| Build | Behaviour |
|---|---|
| No defines | Offline. Falls back to the built-in responses in `AiService`. The header reads "Offline mode". |
| `ANTHROPIC_API_KEY` | Calls `api.anthropic.com` directly. **Development only** — see the warning below. |
| `COACH_PROXY_URL` | Calls your proxy, which holds the key. **Use this for anything you release.** |

## Running it in development

```bash
flutter run --dart-define=ANTHROPIC_API_KEY=sk-ant-...
```

> **Do not ship a build made this way.** An APK is a zip file. Anyone who
> downloads it can unpack it and read the key out of the binary, then spend
> against your account until you notice and rotate it. `--dart-define` only
> keeps the key out of *git* — it does not keep it out of the app.

## Shipping it

Put a small proxy in front. The app sends the conversation, the proxy adds the
key and forwards to the Messages API, and the key never leaves your server.

```bash
flutter build apk --release --dart-define=COACH_PROXY_URL=https://your-worker.workers.dev/chat
```

A Cloudflare Worker is about the smallest thing that does the job, and the free
tier covers a lot of chat traffic. Set `ANTHROPIC_API_KEY` as a Worker secret
(`wrangler secret put ANTHROPIC_API_KEY`), never as a plain variable:

```js
export default {
  async fetch(request, env) {
    if (request.method !== 'POST') return new Response('Not found', { status: 404 });

    const body = await request.json();

    // Pin the expensive knobs server-side. The client is untrusted — a patched
    // APK could otherwise ask for a bigger model or a huge max_tokens and bill
    // it to you.
    const upstream = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-api-key': env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
        'anthropic-beta': 'server-side-fallback-2026-07-01',
      },
      body: JSON.stringify({
        ...body,
        model: 'claude-opus-5',
        max_tokens: Math.min(body.max_tokens ?? 1024, 1024),
        fallbacks: 'default',
      }),
    });

    // Stream straight through; the app parses the SSE frames itself.
    return new Response(upstream.body, {
      status: upstream.status,
      headers: { 'content-type': 'text/event-stream' },
    });
  },
};
```

This proxy is also the only place you can add the things a public app needs and
a raw key cannot give you: per-user rate limits, abuse blocking, and a spend
cap. Worth adding before launch, not after.

## Cost

`claude-opus-5` is $5 per million input tokens and $25 per million output.
A single exchange is roughly 600 input and 150 output tokens including the
system prompt and history, so on the order of half a cent. Requests use
`effort: low`, which keeps replies fast and cheap — they are a few sentences of
encouragement, not analysis.

To trade quality for cost without touching code:

```bash
flutter build apk --dart-define=COACH_MODEL=claude-sonnet-5 ...
```

## Changing how the coach talks

The persona is `_systemPrompt` in `lib/services/ai_service.dart`. It sets the
voice, keeps replies to a few sentences, and tells the coach to read the room —
fire for someone chasing a goal, steadiness for someone who sounds defeated.

It also instructs the coach to drop the hype entirely and point toward real help
if someone describes self-harm, suicidal thoughts, abuse, or a crisis. A
motivational app attracts people at their lowest, and "no excuses, push harder"
is the wrong answer to some of what they will type. **Keep that paragraph** if
you rewrite the prompt.

Conversation history is capped at `_maxHistory` (20 messages, 10 exchanges) so
requests do not grow without bound.
