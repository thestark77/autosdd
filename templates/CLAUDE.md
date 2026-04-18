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
- Single `response()` for ALL backend responses
- Single `postRequest()` for ALL frontend requests (injects device metadata)
- Audit trail on all data modifications

## Workflow

1. Every change uses **SDD** — explore → propose → spec → design → tasks → apply → verify
2. Orchestrator delegates, sub-agents execute. Never implement inline.
3. **TDD mandatory**: RED → GREEN → REFACTOR. No code without a failing test first.
4. Auto-update Three Critical Context Files (guidelines.md, user_context.md, business_logic.md) when relevant info discovered
5. Save decisions to Engram immediately after making them
6. If blocked, mark `// TODO` + save to Engram as `user-pending`. Continue with everything else.
7. Commit after completing key modules. Push to main.

## Testing

```bash
rtk vitest run                    # Unit/integration tests (real DB, no mocks)
rtk playwright test               # E2E tests (browser flows)
rtk tsc                           # Type check
rtk lint                          # Lint check
```

See autoSDD v3 skill for full testing strategy.

## Quality Gates (every change must pass)

1. All tests pass (`vitest` + `playwright`)
2. TypeScript clean (`tsc`)
3. Lint clean
4. Spec compliance verified by independent sub-agent
5. Dual review via `/judgment-day` for critical changes

## Skill Management (CRITICAL)

**ALL skills are OFF by default.** Activate ONLY what you need, deactivate when done.

- Library: `.agents/skills/` (project) + `~/.claude/skills/` (user)
- Activate: create symlink in `.claude/skills/` → `.agents/skills/<name>`
- Deactivate: remove symlink from `.claude/skills/`
- **NEVER leave skills active after completing a task**
- Unused skills waste context, increase cost, degrade response quality

| Context | Activate these skills ONLY |
|---------|--------------------------|
| React/Next.js | `next-best-practices`, `vercel-react-best-practices` |
| Tests | `test-driven-development`, `javascript-testing-patterns` |
| E2E | `e2e-testing-patterns` |
| Prisma/DB | `prisma-client-api`, `prisma-cli`, `postgresql-table-design` |
| Public UI | `frontend-design` |
| Admin UI | `interface-design` |
| API errors | `error-handling-patterns` |
| Review | `judgment-day` |

## Agent Operational Freedom

You are a senior developer with FULL autonomy over the local environment.

- **LOCAL database is yours**: create, read, update, delete data freely. Truncate tables, run seeds, reset migrations — no permission needed.
- **Start dev server** (`pnpm dev`) and test features via Playwright MCP or curl whenever needed
- **Use ALL MCPs proactively**: Playwright (browser), Prisma (DB), Railway (deploy), Sentry (errors), GitHub (issues/PRs)
- **Ask before guessing**: If clarifying questions would significantly increase success probability, ASK THEM first
- **Suggest improvements**: Proactively propose enhancements within technical capability
- **Testing = cost/benefit**: Use whatever is most efficient — e2e, unit, curl, MCP tools, direct DB queries

## MCPs Available

| MCP | Use |
|-----|-----|
| Playwright | E2E testing, visual verification, form testing |
| Prisma | DB queries, schema management, migrations — `pnpm dlx -y mcp-remote https://mcp.prisma.io/mcp` |
| Sentry | Production error tracking |
| Railway | Deployment, logs, variables |
| Engram | Persistent memory across sessions |
| Linear | Issue/project tracking |

## Hooks (`.claude/settings.json`)

- **PreToolUse** `git push*`: Runs `pnpm validate` before ANY push. Blocks push if lint, typecheck, or tests fail.
- Never skip hooks (`--no-verify`). Fix the issue instead.

## RTK (Token Optimization)

**ALWAYS prefix commands with `rtk`**. Even in chains: `rtk git add . && rtk git commit -m "msg" && rtk git push`.
RTK filters noise, saves 60-90% tokens. If RTK has no filter, it passes through — always safe.

```bash
rtk vitest run          # Tests — 99% savings
rtk tsc                 # TypeCheck — 83% savings
rtk lint                # Lint — 84% savings
rtk git status          # Git — 59-80% savings
rtk prisma migrate dev  # Prisma — 88% savings
```

## Validation

```bash
pnpm validate           # lint + typecheck + unit/integration tests
pnpm validate:full      # lint + typecheck + all tests + e2e
```

Run `pnpm validate` before every push. The pre-push hook enforces this automatically.

## Project Commands

```bash
pnpm dev                          # Dev server (localhost:3000)
rtk prisma migrate dev            # Run migrations
rtk prisma db seed                # Seed database
rtk prisma generate               # Regenerate client
```

## Path Aliases

`@/*` · `@components/*` · `@lib/*` · `@stores/*` · `@config/*`

## autoSDD — Active Framework (DO NOT REMOVE)

autoSDD v3 is the ACTIVE development framework for this project.
ALL prompts go through autoSDD unless the user explicitly opts out.

### Default Behavior
- Every prompt → Flow Router → CREA Prompt Refine → Execute Flow → Outcome Collection
- CREA framework (Context, Role, Specificity, Action) on ALL prompt creation
- prompt-engineering-patterns skill on ALL prompt refinement
- 5 flows: Development, Code Review, Debugging, Research, Self-Improvement
- Orchestrator delegates to sub-agents, NEVER executes directly
- Monitor tool for ALL waiting/watching (NEVER poll)
- RTK prefix on ALL shell commands

### Three Critical Context Files (sacred, auto-updated)
- `context/guidelines.md` — Technical rules and conventions
- `context/user_context.md` — User profile and preferences
- `context/business_logic.md` — Domain knowledge and workflows

### Opt-Out
- `[raw]` prefix: skip framework entirely
- `[no-sdd]` prefix: skip SDD but keep CREA
- `skip autosdd`: natural language opt-out

Read the autoSDD skill: `~/.claude/skills/autosdd/SKILL.md`
