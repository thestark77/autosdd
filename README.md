# AutoSDD — Autonomous Spec-Driven Development

<div align="center">

**"Be Tony Stark"** — Talk to your AI, it asks questions, then builds everything autonomously.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-blue)](https://claude.ai/claude-code)
[![gentle-ai](https://img.shields.io/badge/gentle--ai-FUNDAMENTAL-red)](https://github.com/Gentleman-Programming/gentle-ai)
[![RTK](https://img.shields.io/badge/RTK-Token%20Killer-orange)](https://github.com/thestark77/rtk)
[![Made by Gentleman Programming](https://img.shields.io/badge/Made%20by-Gentleman%20Programming-blueviolet)](https://github.com/Gentleman-Programming)

</div>

---

AutoSDD is an autonomous development framework where AI agents plan, implement, test, and deploy code through a structured pipeline. Every change flows through: **explore → propose → spec → design → tasks → apply → verify → certify → deploy**.

The AI doesn't just write code — it asks the right questions first, then executes the full pipeline from spec to certified deployment, notifying you when it needs approval or something blocks it.

---

## Vision: Iron Man Mode

Imagine talking to your development system like Tony Stark talks to JARVIS:

1. **You speak** — voice or text, even from WhatsApp or Telegram
2. **AI clarifies** — proactively asks questions until there is zero ambiguity
3. **AI executes** — full pipeline from spec to certified deployment
4. **AI notifies** — sends you updates, asks for approvals via messaging

No more hand-holding every step. You define intent, the system handles execution.

---

## How It Works

### The Autonomous Loop

```
USER INPUT (voice/text/chat)
    ↓
PROMPT ENGINEERING (cleanup + structure)
    ↓
PROACTIVE CLARIFICATION (AI asks questions)
    ↓
┌─────────────────────────────────────────┐
│  PLAN PHASE                             │
│  explore → propose → spec →             │
│  design → tasks                         │
│  Quality gate: GIVEN/WHEN/THEN          │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│  BUILD PHASE (TDD)                      │
│  RED → GREEN → REFACTOR                 │
│  Quality gate: ALL tests pass           │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│  VERIFY PHASE                           │
│  Independent agent validates            │
│  Quality gate: 0 CRITICAL findings      │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│  CERTIFY PHASE                          │
│  Dual review (judgment-day)             │
│  Both judges must PASS                  │
└─────────────────────────────────────────┘
    ↓
COMMIT → DEPLOY → NOTIFY USER
```

### SDD Phases

| Phase | Command | What it does |
|-------|---------|-------------|
| Explore | `/sdd-explore <topic>` | Investigate codebase, compare approaches — no files changed |
| Propose | (via `/sdd-new`) | Architecture proposal with rollback plan |
| Spec | (via `/sdd-new`) | GIVEN/WHEN/THEN scenarios for every requirement |
| Design | (via `/sdd-new`) | File structure, sequence diagrams, dependency map |
| Tasks | (via `/sdd-new`) | Numbered task list including test tasks |
| Apply | `/sdd-apply` | TDD implementation in batches (RED → GREEN → REFACTOR) |
| Verify | `/sdd-verify` | Independent validation against specs |
| Archive | `/sdd-archive` | Close change, persist final state to Engram |

### Meta-Commands

| Command | What it does |
|---------|-------------|
| `/sdd-new <change>` | Start new change — triggers full pipeline |
| `/sdd-ff <name>` | Fast-forward through all planning phases |
| `/sdd-continue` | Run the next dependency-ready phase |
| `/sdd-init` | Initialize SDD context for a project |
| `/sdd-onboard` | Guided walkthrough using your real codebase |

---

## Prerequisites

### Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| [Claude Code](https://claude.ai/claude-code) | AI development CLI | `npm install -g @anthropic-ai/claude-code` |
| [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) | **FUNDAMENTAL** — Skill management TUI, SDD orchestration | `cargo install gentle-ai` |
| [RTK (Rust Token Killer)](https://github.com/thestark77/rtk) | Token-optimized command output (60–90% savings) | `cargo install rtk` |
| Node.js 22+ | Runtime | [nodejs.org](https://nodejs.org) |
| pnpm | Package manager | `npm install -g pnpm` |

> **gentle-ai is FUNDAMENTAL.** It manages skill installation, lifecycle, and SDD orchestration. Install it first.

### Required MCP Servers

MCPs (Model Context Protocol) extend Claude Code with real-world capabilities. These are critical to the framework:

| MCP | Purpose | Configuration |
|-----|---------|--------------|
| [Engram](https://github.com/nicobailon/engram) | Persistent memory across sessions and compactions | Add to `.claude/settings.json` |
| [Playwright](https://github.com/anthropics/claude-code/tree/main/packages/playwright-mcp) | E2E testing, visual verification, form testing | `npx @anthropic-ai/playwright-mcp` |
| [Prisma](https://mcp.prisma.io) | Database queries, schema management, migrations | `pnpm dlx -y mcp-remote https://mcp.prisma.io/mcp` |
| [Railway](https://github.com/nicholasgriffintn/railway-mcp-server) | Deployment, logs, environment variables | Add to settings |
| [Sentry](https://github.com/sentry-ai/sentry-mcp-server) | Production error tracking, stack traces | Add to settings |
| [Linear](https://linear.app) | Issue/project tracking, PR linking | Claude.ai integration |

See [docs/mcp-setup.md](docs/mcp-setup.md) for full configuration examples.

---

## Skills System

AutoSDD uses a **skill library** — focused instruction sets that the AI reads before performing specific tasks. Skills are scoped, composable, and controlled.

> **ALL skills are OFF by default.** Activating unused skills wastes tokens and degrades quality.

### How Skills Work

```bash
# Activate a skill for the current task
ln -s ../../.agents/skills/<name> .claude/skills/<name>

# Deactivate after the task is done
rm -f .claude/skills/<name>

# NEVER leave skills active between tasks
```

### Project-Level Skills (`.agents/skills/`)

| Skill | When to use |
|-------|------------|
| `test-driven-development` | Before writing ANY implementation code |
| `javascript-testing-patterns` | Writing Vitest unit/integration tests |
| `e2e-testing-patterns` | Playwright E2E tests |
| `next-best-practices` | Next.js code — RSC, routes, data patterns |
| `prisma-client-api` | Database queries, CRUD, transactions |
| `prisma-cli` | Migrations, generate, db push/seed |
| `prisma-database-setup` | PostgreSQL connection configuration |

### User-Level Skills (`~/.claude/skills/`)

| Skill | When to use |
|-------|------------|
| `vercel-react-best-practices` | React/Next.js performance optimization |
| `postgresql-table-design` | Schema design, indexing strategies |
| `error-handling-patterns` | API resilience, exception design |
| `frontend-design` | Landing pages, public-facing UI |
| `interface-design` | Dashboards, admin panels |
| `prompt-engineering-patterns` | Prompt design, voice input processing |
| `judgment-day` | Dual adversarial review for critical changes |
| `branch-pr` | PR creation workflow |
| `issue-creation` | GitHub issue creation |

Install skills via `gentle-ai` TUI or: `npx -y skills add <skill-name>`

See [docs/skill-lifecycle.md](docs/skill-lifecycle.md) for the full activation protocol.

---

## Testing Strategy

AutoSDD enforces strict TDD — **RED → GREEN → REFACTOR**. No code ships without a failing test first.

### Three Layers

| Layer | Tool | What to test |
|-------|------|-------------|
| Unit | Vitest | Pure functions, validation schemas, JWT logic |
| Integration | Vitest (`pool: 'forks'`) | Models, tenant isolation, soft delete, API routes |
| E2E | Playwright | User flows, auth, routing, mobile responsiveness |

### Critical Technical Decisions

| Decision | Why |
|----------|-----|
| `pool: 'forks'` for integration tests | MANDATORY when using `AsyncLocalStorage` — thread pool breaks context propagation |
| `envFile` / `setupFiles` loads env BEFORE module imports | Prevents `process.exit(1)` in strict env validation |
| Real database for integration tests | NEVER mock Prisma — mocks hide real bugs |
| `ioredis-mock` in test environment | Redis behavior without a running server |

### Quality Gates

Every change must pass ALL gates before the next phase:

| Phase | Gate | Fails if... |
|-------|------|-------------|
| spec | Scenarios complete | Missing GIVEN/WHEN/THEN for any requirement |
| design | Architecture sound | Violates base constraints |
| tasks | Test tasks included | No test task exists for the change |
| apply | TDD compliance | Code written before failing test |
| apply | Tests pass | `rtk vitest run` or `rtk playwright test` has failures |
| apply | TypeScript clean | `rtk tsc` has errors |
| apply | Lint clean | `rtk lint` has errors |
| verify | Spec compliance | Implementation diverges from spec scenarios |
| verify | E2E verification | Playwright navigation reveals broken flows |
| certify | Dual review pass | Either judge reports CRITICAL issues |

```bash
pnpm validate        # lint + typecheck + unit/integration tests
pnpm validate:full   # + E2E tests
```

See [docs/testing-strategy.md](docs/testing-strategy.md) for full detail.

---

## Agent Architecture

```
ORCHESTRATOR (Opus — coordinates, never executes directly)
    ├── sdd-explore  (Sonnet — reads code, structural analysis)
    ├── sdd-propose  (Opus   — architectural decisions)
    ├── sdd-spec     (Sonnet — structured writing)
    ├── sdd-design   (Opus   — architecture decisions)
    ├── sdd-tasks    (Sonnet — mechanical breakdown)
    ├── sdd-apply    (Sonnet — TDD implementation)
    ├── sdd-verify   (Sonnet — validation against spec)
    └── sdd-archive  (Sonnet — close and persist)
```

The orchestrator **never** writes code inline. It delegates to sub-agents and synthesizes their results. Each sub-agent gets injected compact skill rules, not full files, keeping every context lean.

---

## Persistent Memory (Engram)

AutoSDD uses [Engram](https://github.com/nicobailon/engram) for persistent memory that survives sessions and compactions:

- **Proactive saves**: Every decision, bug fix, and discovery is saved immediately — not when asked
- **Session summaries**: Mandatory before ending any session
- **Cross-session recovery**: Context restored after compaction or new session
- **Structured topic keys**: `sdd/{change-name}/{artifact}` for deterministic retrieval

### Artifact Topic Keys

| Artifact | Topic Key |
|----------|-----------|
| Project context | `sdd-init/{project}` |
| Exploration | `sdd/{change-name}/explore` |
| Proposal | `sdd/{change-name}/proposal` |
| Spec | `sdd/{change-name}/spec` |
| Design | `sdd/{change-name}/design` |
| Tasks | `sdd/{change-name}/tasks` |
| Apply progress | `sdd/{change-name}/apply-progress` |
| Verify report | `sdd/{change-name}/verify-report` |
| Archive report | `sdd/{change-name}/archive-report` |

---

## Claude Code Hooks

Hooks automate quality enforcement without manual intervention:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git push*)",
        "hooks": [
          {
            "type": "command",
            "command": "pnpm validate"
          }
        ]
      }
    ]
  }
}
```

The `git push` hook blocks ALL pushes unless `pnpm validate` passes. Never skip it with `--no-verify`. Fix the issue instead.

See [docs/hooks.md](docs/hooks.md) for the full hook event reference.

---

## Token Optimization with RTK

**ALWAYS prefix commands with `rtk`** for 60–90% token savings. RTK passes through unknown commands unchanged — it is always safe to use.

```bash
rtk vitest run          # 99% savings
rtk tsc                 # 83% savings
rtk lint                # 84% savings
rtk git status          # 59–80% savings
rtk prisma migrate dev  # 88% savings
rtk next build          # 87% savings
```

Even in chains:

```bash
# Wrong
git add . && git commit -m "msg" && git push

# Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

---

## Iron Man Mode (Roadmap)

### Voice Input Pipeline

```
1. User sends audio/text via WhatsApp or Telegram
2. AI cleans and formats with punctuation
3. Passes through prompt-engineering-patterns skill
4. Generates SDD-ready prompt for orchestrator
5. AI asks clarifying questions until zero ambiguity
6. Executes full pipeline autonomously
7. Notifies user on completion, blocker, or approval needed
```

### WhatsApp / Telegram Bridge

- Bidirectional communication via Telegram Bot API
- User sends audio or text prompts from anywhere
- System sends notifications: completions, blockers, approval requests
- Execution runs locally on the developer's machine

### Proactive Conversation Management

- System guides the conversation, not the user
- Suggests optimal execution order
- Tracks pending tasks, priorities, and blockers
- Asks clarifying questions BEFORE starting execution
- Redirects user to optimal path when off-track

See [docs/iron-man-roadmap.md](docs/iron-man-roadmap.md) for full specification.

---

## Context Directory

Every AutoSDD project maintains a `context/` directory with persistent knowledge that agents read before making decisions:

| File | Purpose | When to update |
|------|---------|---------------|
| `base_requirements.md` | Immutable conventions, patterns, security | Rarely — foundational rules |
| `requirements.md` | Project specs, schema, phases, permissions | When user input affects the plan |
| `autosdd.md` | Autonomous development framework | When framework evolves |
| `business_logic.md` | Business domain knowledge, terminology, rules | Continuously — as user shares context |

`business_logic.md` is the living record of everything that code alone cannot capture: what the product does, who uses it, what the terminology means, and what the non-obvious rules are. Agents write to it proactively whenever the user shares domain knowledge.

Copy `templates/business_logic.md` into `your-project/context/business_logic.md` and fill it in as your project evolves.

---

## Quick Start

```bash
# 1. Install prerequisites
npm install -g @anthropic-ai/claude-code
cargo install gentle-ai
cargo install rtk

# 2. Configure MCP servers (see docs/mcp-setup.md)

# 3. Install skills via gentle-ai TUI or:
npx -y skills add autosdd

# 4. Add AutoSDD to your project
cp templates/CLAUDE.md your-project/CLAUDE.md
cp templates/autosdd.md your-project/context/autosdd.md
cp templates/business_logic.md your-project/context/business_logic.md

# 5. Initialize SDD in Claude Code
/sdd-init

# 6. Start building
/sdd-new my-feature
```

---

## Non-Negotiable Principles

1. **No code without a test** — TDD is not optional. RED → GREEN → REFACTOR.
2. **No mock databases** — Integration tests hit real PostgreSQL. Mocks hide real bugs.
3. **No skipped quality gates** — Every phase must pass before the next begins.
4. **No manual verification when automated is possible** — If Playwright can check it, write a test.
5. **No context loss** — Every decision, bug, and discovery gets saved to Engram immediately.
6. **No silent failures** — If self-correction fails 3 times, escalate. Never loop infinitely.
7. **Specs are the source of truth** — Implementation matches specs, not the other way around.

---

## File Structure

```
autosdd/
├── README.md                    # This file
├── skill/
│   └── SKILL.md                 # Claude Code skill (install via gentle-ai)
├── templates/
│   ├── CLAUDE.md                # Template CLAUDE.md for new projects
│   ├── autosdd.md               # Template autosdd.md (the framework itself)
│   └── business_logic.md        # Template for business domain knowledge
└── docs/
    ├── testing-strategy.md      # Full testing strategy
    ├── skill-lifecycle.md       # Skill activation/deactivation protocol
    ├── mcp-setup.md             # MCP server configuration guide
    ├── iron-man-roadmap.md      # Voice/Telegram integration roadmap
    └── hooks.md                 # Claude Code hooks — full event reference
```

---

## Related Projects

| Project | Purpose |
|---------|---------|
| [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) | **FUNDAMENTAL** — Skill management TUI and SDD orchestration |
| [RTK](https://github.com/thestark77/rtk) | Rust Token Killer — 60–90% token savings on common commands |
| [skills.sh](https://skills.sh) | Claude Code skills marketplace |
| [Engram](https://github.com/nicobailon/engram) | Persistent memory MCP for Claude Code |

---

## Created By

[**Gentleman Programming**](https://github.com/Gentleman-Programming) — Senior SaaS Architect, Google Developer Expert & Microsoft MVP. Building the future of autonomous development.

---

## License

MIT — see [LICENSE](LICENSE)
