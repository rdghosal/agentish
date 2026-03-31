# agentish

All the ish related to agents.

Configuration, conventions, and skills for AI coding assistants. Stuff to make your AI pair programmer less chaotic and more helpful.

## What's in the box

| Thing | What it does |
|-------|--------------|
| `AGENTS.md` | The brain — tells the AI how to behave, commit, validate |
| `conventions/` | Language-specific style guides (Rust, TypeScript) |
| `skills/` | 3 custom skills + setup script for external sources |

## Setup

### For pi

```bash
git clone git@github.com:rdghosal/agentish.git ~/code/agentish
ln -s ~/code/agentish/skills ~/.config/pi/agent/skills
cd ~/code/agentish && ./setup-skills.sh
```

Or symlink the pieces you want if you've got existing config.

### For other tools

`AGENTS.md` and `skills/` work with any AI coding assistant that supports custom instructions. Adapt as needed.

## Skills

Skills are on-demand capabilities. Each one has a `SKILL.md` that loads when the task matches.

### Custom Skills

| Skill | Does what |
|-------|-----------|
| `init-pre-commit` | Set up pre-commit hooks (linting, formatting, security, complexity) |
| `prd-to-todos` | Break a PRD into grabbable Pi todos |
| `review-and-commit` | Review code and organize commits properly |

### External Skills

Run `./setup-skills.sh` to install skills from external sources:

| Source | Skills |
|--------|--------|
| [Impeccable](https://impeccable.style) | 21 design commands (`/audit`, `/polish`, `/critique`, etc.) |
| [mattpocock/skills](https://github.com/mattpocock/skills) | `write-a-prd`, `prd-to-plan`, `grill-me`, `design-an-interface`, `tdd`, `improve-codebase-architecture` |
| [mitsuhiko/agent-stuff](https://github.com/mitsuhiko/agent-stuff) | `tmux`, `uv`, `update-changelog`, `github`, `sentry`, etc. |

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
