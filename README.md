# agentish

Configuration for AI coding assistants. Provides agent instructions, coding conventions, and a library of specialized skills.

## What's Inside

| Component | Purpose |
|-----------|---------|
| `AGENTS.md` | Master instructions for AI behavior — accuracy, security, commit conventions, validation |
| `conventions/` | Language-specific coding standards (Rust, TypeScript) |
| `skills/` | Library of 30+ specialized capabilities for design, planning, and development |

## Installation

### For pi (recommended)

```bash
# Clone the repo
git clone git@github.com:rdghosal/agentish.git ~/.config/pi/agent

# Or symlink AGENTS.md and skills if you have existing config
ln -s /path/to/agentish/AGENTS.md ~/.config/pi/agent/AGENTS.md
ln -s /path/to/agentish/skills ~/.config/pi/agent/skills
ln -s /path/to/agentish/conventions ~/.config/pi/agent/conventions
```

### For other AI tools

The `AGENTS.md` and `skills/` can be adapted for any AI coding assistant that supports custom instructions. See your tool's documentation for how to load custom prompts.

## Project Structure

```
agentish/
├── AGENTS.md                    # Master agent instructions
├── conventions/
│   ├── rust.md                  # Rust coding standards
│   └── typescript.md            # TypeScript coding standards
├── skills/                      # Git submodule → rdghosal/skills
│   ├── adapt/                   # Responsive/adaptive design
│   ├── animate/                 # Motion & micro-interactions
│   ├── arrange/                 # Layout & spacing
│   ├── audit/                   # Accessibility/performance audits
│   ├── bolder/                  # Amplify safe designs
│   ├── clarify/                 # Improve UX copy
│   ├── colorize/                # Strategic color
│   ├── critique/                # UX evaluation
│   ├── delight/                 # Joyful moments
│   ├── design-an-interface/     # Generate interface options
│   ├── distill/                 # Strip to essence
│   ├── extract/                 # Extract design system components
│   ├── frontend-design/         # Production-grade UI creation
│   ├── grill-me/                # Stress-test plans via interview
│   ├── harden/                  # Error handling & edge cases
│   ├── improve-codebase-arch/   # Architecture refactoring
│   ├── init-pre-commit/         # Pre-commit setup
│   ├── normalize/               # Design system consistency
│   ├── onboard/                 # First-time user experience
│   ├── optimize/                # Performance improvement
│   ├── overdrive/               # Technically ambitious UI
│   ├── polish/                  # Final quality pass
│   ├── prd-to-plan/             # PRD → implementation plan
│   ├── prd-to-todos/            # PRD → Pi todos
│   ├── quieter/                 # Tone down bold designs
│   ├── review-and-commit/       # Code review & commits
│   ├── tdd/                     # Test-driven development
│   ├── teach-impeccable/        # Design context setup
│   ├── tmux/                    # Remote control tmux
│   ├── typeset/                 # Typography improvement
│   ├── update-changelog/        # Changelog conventions
│   ├── uv/                      # Python with uv
│   └── write-a-prd/             # PRD creation via interview
└── .pi/
    └── todos/                   # Pi todo tracking
```

## Skills

Skills are specialized capabilities loaded on-demand. Each skill has a `SKILL.md` with:

- `name` — identifier
- `description` — when to use this skill
- Markdown content — instructions for the AI

### Design & UI Skills

| Skill | Description |
|-------|-------------|
| `adapt` | Adapt designs across screen sizes, devices, contexts |
| `animate` | Purposeful animations and micro-interactions |
| `arrange` | Layout, spacing, and visual rhythm |
| `audit` | Comprehensive accessibility/performance audit |
| `bolder` | Amplify safe or boring designs |
| `clarify` | Improve UX copy, errors, labels |
| `colorize` | Add strategic color |
| `critique` | UX evaluation with actionable feedback |
| `delight` | Joyful, memorable touches |
| `distill` | Strip to essence, remove complexity |
| `extract` | Extract design system components |
| `frontend-design` | Production-grade UI with high design quality |
| `harden` | Error handling, edge cases, resilience |
| `normalize` | Match design system, ensure consistency |
| `onboard` | Onboarding flows and empty states |
| `optimize` | Performance improvement |
| `overdrive` | Technically ambitious implementations |
| `polish` | Final quality pass before shipping |
| `quieter` | Tone down overly bold designs |
| `typeset` | Typography improvement |

### Planning & Development Skills

| Skill | Description |
|-------|-------------|
| `design-an-interface` | Generate multiple interface designs |
| `grill-me` | Interview user to stress-test a plan |
| `improve-codebase-architecture` | Find refactoring opportunities |
| `init-pre-commit` | Set up pre-commit configuration |
| `prd-to-plan` | Turn PRD into implementation plan |
| `prd-to-todos` | Break PRD into Pi todos |
| `review-and-commit` | Review code and organize commits |
| `tdd` | Test-driven development |
| `write-a-prd` | Create PRD via user interview |

### Tooling Skills

| Skill | Description |
|-------|-------------|
| `teach-impeccable` | One-time design context setup |
| `tmux` | Remote control tmux sessions |
| `update-changelog` | Changelog conventions |
| `uv` | Use uv instead of pip/python/venv |

## Conventions

Language-specific coding standards that the AI loads when working with that language:

- **Rust** (`conventions/rust.md`) — RFC 430 naming, error handling with `thiserror`, ownership patterns, async best practices, SQLx guidelines
- **TypeScript** (`conventions/typescript.md`) — Strict mode, `unknown` over `any`, Zod for runtime validation, discriminated unions, React patterns

## Philosophy

### Accuracy Over Guessing

The agent asks before assuming. When requirements or context are unclear, it seeks clarification rather than fabricating facts.

### Simple Code

Favor low cyclomatic complexity. Simple code is easier to understand, maintain, and debug — for humans and AI alike.

### Security by Default

- Validate at boundaries
- Whitelist over blacklist
- Never trust client-side validation
- No hardcoded secrets
- Fail closed

### Conventional Commits

All commits follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>)[!]: <short summary>

[optional body]

[optional footers]
```

Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`

### Validation Before Handoff

Run the full validation suite (tests, complexity, type checking) before declaring work complete. Pre-commit hooks are fast guardrails; validation is the comprehensive check.

## Development

```bash
# Install pre-commit hooks
pre-commit install

# Run all checks
pre-commit run --all-files
```

## License

MIT
