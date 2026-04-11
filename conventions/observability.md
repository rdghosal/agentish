# Observability

Code should be diagnosable in production without attaching a debugger.

## Structured Logging

- Use structured logging (key-value/JSON), not string interpolation. `log.info("user created", {userId, plan})` not `log.info("User " + id + " created")`.
- Log at boundaries: incoming requests, outgoing calls, state transitions, error paths.
- Levels mean something: ERROR = needs human attention. WARN = degraded but functional. INFO = business events. DEBUG = developer diagnostics, off in prod.
- Every log entry needs enough context to find the request: request ID, user ID, operation name. No orphan messages.

## Error Context

- Errors must carry causal context. Wrap with _why_ it matters, not just _what_ failed. `"failed to charge subscription: user={id}"` not `"payment error"`.
- Preserve original error in chain. Never swallow cause.
- Don't log-and-throw. Pick one. Logging + rethrowing = duplicate noise.

## Tracing

- Add trace/span context at service boundaries (HTTP handlers, queue consumers, RPC calls).
- Propagate correlation IDs across async boundaries. Don't start new traces mid-request.

## What Not to Log

- Never log secrets, tokens, passwords, PII, or full request bodies containing user data.
- Never log at levels that create noise in prod. High-frequency loops = DEBUG max.
- No log-driven control flow. Logging is observation, not behavior.

## Metrics vs Logs

- Metrics for aggregates (rate, duration, error count). Logs for individual events.
- Name metrics with unit suffix: `request_duration_ms`, `queue_depth_items`.
