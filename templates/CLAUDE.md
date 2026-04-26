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

## autoSDD v4.1 - Active Framework (DO NOT REMOVE)

<!-- autosdd:start -->
autoSDD v4.1 is the ACTIVE development framework. ALL prompts go through autoSDD unless opted out with `[raw]`, `[no-sdd]`, or `skip autosdd`.

### Core Rule
**The orchestrator DELEGATES. It never writes source code (.ts, .tsx, .prisma, etc.) inline.** See SKILL.md Section 1.

### Pipeline
Triage -> Route -> Plan (CREA prompt.md) -> Delegate (sub-agents with skill injection) -> Collect -> Close Version -> Knowledge Update -> Compaction Check

### Full Framework
Read: `~/.claude/skills/autosdd/SKILL.md`

### Key Sections to Internalize
- **Section 1**: Orchestrator identity (delegate, don't execute)
- **Section 3**: CREA applied ONCE on prompt.md (not 3x)
- **Section 4**: Sub-agent launch template (fill-in-the-blank, mandatory)
- **Section 5**: Skill routing (pattern match -> inject rules)

### Skills (orchestrator resolves automatically)
`prompt-engineering-patterns` . `frontend-design` . `interface-design` . `branch-pr` . `judgment-day` . `e2e-testing-patterns` . `error-handling-patterns` . `playwright-cli` . `claude-md-improver` . `feedback-report` . `knowledge-graph`

### SDD Phases (via gentle-ai)
`sdd-init` . `sdd-explore` . `sdd-propose` . `sdd-spec` . `sdd-design` . `sdd-tasks` . `sdd-apply` . `sdd-verify` . `sdd-archive` . `sdd-onboard`

### Three Critical Context Files (sacred, auto-updated)
- `context/guidelines.md` - Technical rules and conventions
- `context/user_context.md` - User profile and preferences
- `context/business_logic.md` - Domain knowledge and workflows

### Tools
- **RTK**: ALWAYS prefix commands with `rtk` (60-90% savings). Read: `~/.claude/skills/_shared/rtk.md`
- **Monitor**: Event-driven waiting (NEVER sleep/poll)

### Shared Protocols
| Protocol | File |
|----------|------|
| Persona | `~/.claude/skills/_shared/persona.md` |
| RTK | `~/.claude/skills/_shared/rtk.md` |
| SDD Orchestrator | `~/.claude/skills/_shared/sdd-orchestrator.md` |
| Engram Memory | `~/.claude/skills/_shared/engram-protocol.md` |
| Model Assignments | `~/.claude/skills/_shared/model-assignments.md` |
<!-- autosdd:end -->
