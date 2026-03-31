# agentish

All the ish related to agents.

Configuration, conventions, and skills for AI coding assistants. Stuff to make your AI pair programmer less chaotic and more helpful.

## What's in the box

| Thing | What it does |
|-------|--------------|
| `AGENTS.md` | The brain — tells the AI how to behave, commit, validate |
| `conventions/` | Language-specific style guides (Rust, TypeScript) |
| `skills/` | 30+ specialized powers for design, planning, dev |

## Setup

### For pi

```bash
git clone git@github.com:rdghosal/agentish.git ~/.config/pi/agent
```

Or symlink the pieces you want if you've got existing config.

### For other tools

`AGENTS.md` and `skills/` work with any AI coding assistant that supports custom instructions. Adapt as needed.

## Skills

Skills are on-demand capabilities. Each one has a `SKILL.md` that loads when the task matches.

### Design-ish

| Skill | Does what |
|-------|-----------|
| `adapt` | Make it work everywhere (screens, devices, contexts) |
| `animate` | Motion and micro-interactions that actually help |
| `arrange` | Fix layouts that feel off |
| `audit` | Accessibility, performance, theming — the full checkup |
| `bolder` | When it's too safe and boring |
| `clarify` | UX copy that actually makes sense |
| `colorize` | Strategic color, not rainbow vomit |
| `critique` | Honest UX feedback |
| `delight` | Little moments of joy |
| `distill` | Strip the noise |
| `extract` | Pull out reusable components |
| `frontend-design` | Production UI that doesn't look like AI slop |
| `harden` | Error handling, edge cases, resilience |
| `normalize` | Match your design system |
| `onboard` | First-time user experience |
| `optimize` | Make it fast |
| `overdrive` | Technically ambitious stuff (shaders, physics, the fun things) |
| `polish` | Final pass before shipping |
| `quieter` | When it's too loud |
| `typeset` | Typography that works |

### Planning-ish

| Skill | Does what |
|-------|-----------|
| `design-an-interface` | Generate different interface options |
| `grill-me` | Stress-test your plan via interview |
| `improve-codebase-architecture` | Find refactoring opportunities |
| `prd-to-plan` | PRD → implementation plan |
| `prd-to-todos` | PRD → grabbable todos |
| `write-a-prd` | Create a PRD through conversation |

### Dev-ish

| Skill | Does what |
|-------|-----------|
| `init-pre-commit` | Set up pre-commit hooks |
| `review-and-commit` | Review and commit properly |
| `tdd` | Test-driven development |
| `tmux` | Remote control tmux |
| `uv` | Python with uv instead of pip hell |
| `update-changelog` | Changelog conventions |

## Conventions

Language-specific rules the AI loads when working in that language:

- **Rust** — naming, error handling, ownership, async, SQLx
- **TypeScript** — strict mode, `unknown` over `any`, Zod validation, React patterns

## The philosophy-ish

**Don't guess.** Ask when unclear. Fabricating facts leads to wrong solutions.

**Keep it simple.** Low cyclomatic complexity. Code that humans and AI can both understand.

**Secure by default.** Validate at boundaries. No hardcoded secrets. Fail closed.

**Conventional commits.** `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`.

**Validate before handoff.** Tests, complexity, type checking — run the full suite.

## Dev

```bash
pre-commit install
pre-commit run --all-files
```
