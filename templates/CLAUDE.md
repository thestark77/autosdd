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

## autoSDD — Active Framework (DO NOT REMOVE)

<!-- autosdd:start -->
autoSDD v4 is the ACTIVE development framework. ALL prompts go through autoSDD unless opted out with `[raw]`, `[no-sdd]`, or `skip autosdd`.

**Core pipeline**: Prompt Analyst → Feedback Detector → Flow Router → CREA Refine → Execute → Outcome Collection → Knowledge Update

**Read the full framework**: `~/.claude/skills/autosdd/SKILL.md`

### Ecosystem (auto-installed)

#### Skills (orchestrator resolves automatically — user doesn't need to name them)

| Skill | When to Use |
|-------|------------|
| `autosdd` | ALWAYS — flow router + CREA + feedback engine |
| `prompt-engineering-patterns` | Every prompt creation — CREA techniques |
| `frontend-design` | Public-facing UI — pages, components, layouts |
| `interface-design` | Admin/internal UI — dashboards, tables, panels |
| `branch-pr` | Shipping work — PR creation |
| `judgment-day` | Critical code — security, finance, 5+ file changes |
| `e2e-testing-patterns` | E2E tests — Playwright/Cypress coverage |
| `error-handling-patterns` | Error management — API routes, validation, external APIs |
| `playwright-cli` | Browser automation — visual verify, screenshots (ALWAYS --headed) |
| `claude-md-improver` | CLAUDE.md quality — audit, improve, restructure |
| `feedback-report` | User feedback — `/feedback [timerange]` |
| `knowledge-graph` | Memory visualization — `/knowledge-graph` |
| `skill-creator` | Creating new SKILL.md files |
| `postgresql-table-design` | DB schema design — tables, indexes, RLS |

#### SDD Phase Skills (via gentle-ai)

`sdd-init` · `sdd-explore` · `sdd-propose` · `sdd-spec` · `sdd-design` · `sdd-tasks` · `sdd-apply` · `sdd-verify` · `sdd-archive` · `sdd-onboard`

#### MCPs

| MCP | When |
|-----|------|
| Engram | Persistent memory — ALL phases |
| Context7 | Live library docs — prompt enrichment |
| Playwright | Browser automation — apply, verify |
| Prisma | DB management — apply, verify |
| Linear | Issue tracking — orchestrator |
| GitHub | PRs, issues — orchestrator |

#### Tools

- **RTK**: ALWAYS prefix commands with `rtk` (60-90% token savings). Read: `~/.claude/skills/_shared/rtk.md`
- **Monitor**: Event-driven waiting (NEVER sleep/poll)

### Three Critical Context Files (sacred, auto-updated)

- `context/guidelines.md` — Technical rules and conventions
- `context/user_context.md` — User profile and preferences
- `context/business_logic.md` — Domain knowledge and workflows

### Bidirectional Feedback (v4)

- AI analyzes EVERY user prompt for quality, skill gaps, and optimization opportunities
- User feedback is detected and persisted automatically to guidelines/user_context/Engram
- `feedback.md` auto-generated at version close in `context/appVersions/vX.Y.Z/`
- `/feedback [timerange]` for aggregate reports · `/knowledge-graph` for memory visualization

### Shared Protocols

| Protocol | File |
|----------|------|
| Persona & Rules | `~/.claude/skills/_shared/persona.md` |
| RTK Token Optimization | `~/.claude/skills/_shared/rtk.md` |
| SDD Orchestrator | `~/.claude/skills/_shared/sdd-orchestrator.md` |
| Engram Memory | `~/.claude/skills/_shared/engram-protocol.md` |
| Model Assignments | `~/.claude/skills/_shared/model-assignments.md` |
<!-- autosdd:end -->
