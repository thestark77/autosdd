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

AutoSDD v3 is a **self-improving** autonomous development framework. AI agents plan, implement, test, deploy, AND optimize their own process. Five flows (Development, Code Review, Debugging, Research, Self-Improvement) with automatic intent detection. CREA prompt engineering on every prompt. Metrics on every execution. The framework literally gets better over time.

The AI doesn't just write code — it asks the right questions first, executes the full pipeline, measures its own performance, and continuously improves its prompts, skills, and workflows.

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

## Remote Control (Mobile)

Control your development session from your phone:

1. Start session: `/rc` in Claude Code (or `claude --rc`)
2. Scan QR code with Claude mobile app (iOS/Android)
3. Full control from phone — same files, MCPs, project context
4. Works on Pro and Max plans

Remote Control REPLACES the need for Telegram/WhatsApp bots. Everything runs locally on your machine — the phone is just a window into the session.

---

## Iron Man Mode (Roadmap)

### Mobile Interface — Remote Control (Available Now)

The primary mobile interface for Iron Man Mode is **Claude Remote Control** — built into Claude Code:

1. Run `/rc` in Claude Code (or `claude --rc`)
2. Scan the QR code with the Claude mobile app (iOS/Android)
3. Full session access from your phone — same project context, MCPs, and tools
4. Send voice messages or text directly from Claude mobile
5. Receive notifications when the AI needs input or completes work

No bot setup, no API tokens, no external services. Remote Control is the native, zero-friction path to mobile access.

### Voice Input Pipeline

```
1. User sends audio/text via Claude mobile app (Remote Control)
2. AI cleans and formats with punctuation
3. Passes through prompt-engineering-patterns skill
4. Generates SDD-ready prompt for orchestrator
5. AI asks clarifying questions until zero ambiguity
6. Executes full pipeline autonomously
7. Notifies user on completion, blocker, or approval needed
```

### Proactive Conversation Management

- System guides the conversation, not the user
- Suggests optimal execution order
- Tracks pending tasks, priorities, and blockers
- Asks clarifying questions BEFORE starting execution
- Redirects user to optimal path when off-track

See [docs/iron-man-roadmap.md](docs/iron-man-roadmap.md) for full specification.

---

## Three Critical Context Files

Every AutoSDD project maintains 3 **sacred living documents** in `context/`. The orchestrator MUST update them whenever relevant information is discovered — this is not optional.

| File | Purpose | Update Triggers |
|------|---------|----------------|
| `guidelines.md` | Technical rules, conventions, constraints, security | New gotcha, convention, post-mortem pattern |
| `user_context.md` | User profile, preferences, workflow style | User provides personal/professional info |
| `business_logic.md` | Domain knowledge, entities, workflows, terminology | Business rule, entity relationship, workflow detail |

Sub-agents never read these files directly. The orchestrator extracts relevant sections and injects them into sub-agent prompts via CREA structure.

Additionally, projects may maintain:

| File | Purpose | When to update |
|------|---------|---------------|
| `requirements.md` | Project specs, schema, phases, permissions | When user input affects the plan |
| `autoSDDv3.md` | Full framework specification (optional local copy) | When framework evolves |

Copy templates from `templates/` into `your-project/context/` and fill them in as your project evolves:

```bash
cp templates/guidelines.md your-project/context/guidelines.md
cp templates/user_context.md your-project/context/user_context.md
cp templates/business_logic.md your-project/context/business_logic.md
```

---

## Quick Start

```bash
# 1. Install prerequisites
npm install -g @anthropic-ai/claude-code   # Or your preferred agent
npx -y gentle-ai@latest                     # SDD skills + Engram memory
cargo install rtk                            # Token optimization (60-90% savings)

# 2. Install autoSDD skill (Claude Code — any OS)
mkdir -p ~/.claude/skills/autosdd
curl -o ~/.claude/skills/autosdd/SKILL.md \
  https://raw.githubusercontent.com/thestark77/autosdd/main/skill/SKILL.md

# 3. Bootstrap your project
cp templates/CLAUDE.md your-project/CLAUDE.md
cp templates/guidelines.md your-project/context/guidelines.md
cp templates/user_context.md your-project/context/user_context.md
cp templates/business_logic.md your-project/context/business_logic.md

# 4. Initialize SDD in Claude Code
/sdd-init

# 5. Start building
/sdd-new my-feature
```

> **Other agents?** Replace `~/.claude/` with `~/.cursor/`, `~/.codex/`, `~/.windsurf/`, `~/.kiro/`, or `~/.vscode/` in step 2.

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
│   └── SKILL.md                 # autoSDD v3 skill (install to ~/.claude/skills/autosdd/)
├── templates/
│   ├── CLAUDE.md                # Template CLAUDE.md for new projects (includes autoSDD activation block)
│   ├── guidelines.md            # Template for technical rules and conventions
│   ├── user_context.md          # Template for user profile and preferences
│   └── business_logic.md        # Template for business domain knowledge
└── docs/
    ├── testing-strategy.md      # Full testing strategy
    ├── skill-lifecycle.md       # Skill activation/deactivation protocol
    ├── mcp-setup.md             # MCP server configuration guide
    ├── iron-man-roadmap.md      # Voice/mobile integration roadmap
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
