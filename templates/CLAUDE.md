@AGENTS.md

# [Project Name] — [Brief Description]

## Stack

[List your stack here, e.g.:]
Next.js 16 (App Router) · Tailwind CSS 4 · Zustand · Zod · Prisma 7 + PostgreSQL · Redis (ioredis) · JWT (jose) · pnpm

## Architecture

- **[Pattern]**: [Description]
- **[Pattern]**: [Description]

## Read Before Coding

| Document | Purpose |
|----------|---------|
| `context/guidelines.md` | **Constitution** — immutable conventions, patterns, security rules |
| `context/user_context.md` | **User Profile** — identity, preferences, workflow style |
| `context/requirements.md` | **Legislation** — project specs, schema, phases, permissions |
| `context/business_logic.md` | **Domain** — business entities, workflows, terminology |

## Critical Constraints

- Code in English, UI in [language] (neutral)
- TypeScript strict, `interface` over `type`, no `any`
- Exact versions in package.json (no `^`)
- Zod validation on EVERY endpoint with error codes (not text)

## Testing

```bash
rtk vitest run                    # Unit/integration tests (real DB, no mocks)
rtk playwright test               # E2E tests (browser flows)
rtk tsc                           # Type check
rtk lint                          # Lint check
```

## Validation

```bash
pnpm validate                     # lint + typecheck + unit/integration
pnpm validate:full                # lint + typecheck + all tests + e2e
```

Run `pnpm validate` before every push.

## Agent Operational Freedom

You are a senior developer with FULL autonomy over the local environment.

- **LOCAL database is yours**: create, read, update, delete data freely
- **Start dev server** (`pnpm dev`) and test features via Playwright or curl
- **Ask before guessing**: If clarifying questions would significantly increase success, ASK FIRST
- **Suggest improvements**: Proactively propose enhancements

<!-- autosdd:start -->
## autoSDD v5.1 - Active Framework (DO NOT REMOVE)

autoSDD v5.1 is the ACTIVE development framework. ALL prompts go through autoSDD unless opted out with `[raw]`, `[no-sdd]`, or `skip autosdd`.

Foundation layer (SDD phases, MCPs, shared protocols) provided by **gentle-ai**. autoSDD extends it with the meta-framework, telemetry, and additional skills.

### Core Rule
**The orchestrator DELEGATES. It never writes source code (.ts, .tsx, .prisma, etc.) inline.** See SKILL.md Section 1.

### Pipeline
Triage -> Route -> Plan (CREA prompt.md) -> Delegate (sub-agents with skill injection) -> Collect -> Close Version -> Knowledge Update -> Compaction Check

### Key Sections to Internalize
- **Section 1**: Orchestrator identity (delegate, don't execute)
- **Section 3**: CREA applied ONCE on prompt.md (not 3x)
- **Section 4**: Sub-agent launch template (fill-in-the-blank, mandatory)
- **Section 5**: Skill routing (pattern match -> inject rules)
- **Step 8**: Compaction protocol (suggest /compact at >50% context)

### Ecosystem

#### Skills installed by autoSDD
| Skill | When |
|-------|------|
| `autosdd` | ALWAYS - flow router + CREA + feedback engine |
| `autosdd-telemetry` | `/audit`, `/improve`, `/self-analysis` - session analysis + self-improvement |
| `prompt-engineering-patterns` | Every prompt creation - CREA techniques |
| `frontend-design` | Public-facing UI - pages, components |
| `interface-design` | Admin/internal UI - dashboards, tables |
| `e2e-testing-patterns` | E2E tests - Playwright/Cypress |
| `error-handling-patterns` | Error management - API routes, validation |
| `playwright-cli` | Browser automation (ALWAYS --headed) |
| `claude-md-improver` | CLAUDE.md - audit, improve |
| `feedback-report` | `/feedback [timerange]` - improvement reports |
| `knowledge-graph` | `/knowledge-graph` - memory visualization |

#### Skills provided by gentle-ai (DO NOT reinstall)
`branch-pr` · `judgment-day` · `skill-creator` · `issue-creation` · `skill-registry` · `go-testing`

#### SDD Phases (via gentle-ai)
`sdd-init` · `sdd-explore` · `sdd-propose` · `sdd-spec` · `sdd-design` · `sdd-tasks` · `sdd-apply` · `sdd-verify` · `sdd-archive` · `sdd-onboard`

#### MCPs (via gentle-ai + autoSDD embedding layer)
Engram (memory + semantic search) · Context7 (docs) · Playwright (browser) · Prisma (DB) · Linear (issues) · GitHub (PRs)

#### Tools
RTK: ALWAYS prefix with `rtk` (60-90% savings) · Monitor: event-driven waiting (NEVER poll) · Auto-Resume: use `autosdd-resume` instead of `claude` for rate-limit recovery (default ON, opt-out: `--no-resume`)

### Three Critical Context Files (sacred, auto-updated)
- `context/guidelines.md` - Technical rules and conventions
- `context/user_context.md` - User profile and preferences
- `context/business_logic.md` - Domain knowledge and workflows

### Pipeline Gates (MANDATORY — verify BEFORE moving to next step)
| Gate | Before... | VERIFY |
|------|-----------|--------|
| G1 | Planning | `mem_search("learnings/{project}")` done · `mem_search("pending")` done |
| G2 | Delegating | prompt.md with CREA · pre-launch gate: template filled (all 6 sections) · `model` set · skills as TEXT |
| G3 | Collecting | Observation saved for each delegation · ≥1 feedback question asked |
| G4 | Closing | feedback.md generated · user feedback persisted · Engram summary saved · README.md + CHANGELOG.md reflect changes |

### Telemetry & Self-Improvement (v5)
- **Session observations**: orchestrator saves compliance notes to Engram at each pipeline step (`telemetry/obs/{project}/{session-marker}/{step}`) — survives compaction and sessions
- **Tiered knowledge**: observations (Engram, per-step) → consolidated learnings by category (Engram, per-pipeline-step retrieval) → promoted rules (SKILL.md, permanent)
- **Bidirectional feedback (MANDATORY)**: ≥1 question per completed feature · feedback.md per version close · missing = NON-COMPLIANT
- `/improve` consolidates observations → learnings → proposes SKILL.md changes → updates `LEARNING.md`
- `/feedback [timerange]` for reports · `/knowledge-graph` for memory visualization

### Hooks (1-line reminders — logic lives in SKILL.md Section 2 checkpoints)
- **SubagentStop**: triggers Step 5 checkpoint (observation + feedback debt)
- **PreCompact**: triggers Step 8 pre-compaction checkpoint (Engram save + plan state)
- **Stop**: triggers pre-close checkpoint (feedback.md + README/CHANGELOG sync, non-blocking)

### Shared Protocols (gentle-ai owns _shared/, autoSDD adds rtk.md only)
| Protocol | File |
|----------|------|
| RTK Token Optimization | `~/.claude/skills/_shared/rtk.md` |
| Persona & Rules | `~/.claude/skills/_shared/persona.md` (gentle-ai) |
| SDD Orchestrator | `~/.claude/skills/_shared/sdd-orchestrator.md` (gentle-ai) |
| Engram Memory | `~/.claude/skills/_shared/engram-protocol.md` (gentle-ai) |

Read the full framework: `~/.claude/skills/autosdd/SKILL.md`
<!-- autosdd:end -->
