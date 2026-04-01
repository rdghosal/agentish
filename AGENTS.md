# Agent Instructions

## Core Behavior

- **Verify with tools.** Read files, run commands, check state. Evidence over inference.
- **Ask when uncertain.** If requirements, context, or facts are unclear, ask. Mark inferences as such.
- **Questions are not tasks.** When the user asks a question, answer it. Only change code when explicitly asked. If ambiguous, ask.

## Design Context

Before UI work, check for `.impeccable.md` in the project root. If present, it is the authoritative source for design direction. Load it only when the task involves UI.

## Code Design

Write human-readable code with low cyclomatic complexity.

- Design data structures first; let them guide the algorithm.
- Start simple. Add complexity only when measurement justifies it.
- Optimize for readability. The next reader (human or agent) should grasp intent quickly.
- Comment _why_, not _what_.
- Keep functions small and single-purpose. Justify new dependencies explicitly.

## Testing

Prefer writing the test first. Red → green → refactor.

- Start with a failing test that encodes the requirement, then write the minimum code to pass it.
- Test behavior, not implementation. Tests should survive refactors.
- Every test should justify its existence — assert a meaningful property, not a line of code.
- Every test should have a clear, distinct intention. Redundant assertions waste signal.

## Security

Treat all external input as untrusted. Validate at boundaries, encode at output.

- Use parameterized queries, argument arrays for shell commands, and context-aware encoding.
- Default to denial for auth. Verify on every request.
- Store secrets in environment variables or secret managers.
- Hash passwords with bcrypt, scrypt, or Argon2.
- Log details internally; return generic messages externally. Keep sensitive data out of logs.

## Coding Conventions

Load the relevant conventions file when a task involves that language (load only what's needed):

- `.rs` files → `~/.config/pi/agent/conventions/rust.md`
- `.ts`/`.tsx` files → `~/.config/pi/agent/conventions/typescript.md`

These take precedence over general habits.

## Commits

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). The pre-commit hook enforces this.

- Summary: imperative mood, ≤72 chars, no trailing period.
- Body: explain _why_. Wrap at 100 chars.
- Breaking changes: append `!` after scope **and** include a `BREAKING CHANGE:` footer.

## Validation

Before declaring work complete, find and run the project's full validation suite (tests, type checking, complexity). If no dedicated command exists, run `pre-commit run --all-files`. Fix all failures before handing off.
