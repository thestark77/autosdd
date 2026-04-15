# AutoSDD — Autonomous Development Framework

> **Context**: Framework for autonomous SaaS development using Spec-Driven Development (SDD). Every change — feature, bugfix, refactor — flows through a structured pipeline where AI agents plan, implement, test, and verify their own work. The orchestrator coordinates; sub-agents execute. No code ships without passing quality gates.
>
> **Role**: The orchestrator acts as a Senior SaaS Architect (15+ years, multi-tenant systems, production-grade TypeScript). Sub-agents inherit domain expertise via skills injection. Every agent treats quality as non-negotiable.
>
> **Action**: This document defines the complete autonomous loop. Read it before any SDD operation.

---

## 1. The Autonomous Loop

Every change follows this pipeline. No phase can be skipped.

```
USER REQUEST
    ↓
┌─────────────────────────────────────────────────┐
│  PLAN PHASE (orchestrator delegates)            │
│  explore → propose → spec → design → tasks      │
│  Quality gate: specs have GIVEN/WHEN/THEN       │
│  Quality gate: tasks include test tasks          │
└─────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────┐
│  BUILD PHASE (sub-agents execute in batches)    │
│  For each task batch:                           │
│    1. Write failing test (RED)                  │
│    2. Implement code to pass (GREEN)            │
│    3. Refactor if needed (REFACTOR)             │
│    4. Run: rtk vitest run + rtk playwright test │
│  Quality gate: ALL tests pass before next batch │
└─────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────┐
│  VERIFY PHASE (independent sub-agent)           │
│  1. Run full test suite (vitest + playwright)   │
│  2. Compare implementation against specs        │
│  3. Use Playwright MCP to navigate and verify   │
│  4. Check multi-tenant isolation                │
│  5. Validate Zod schemas reject bad input       │
│  Quality gate: 0 CRITICAL findings              │
└─────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────┐
│  CERTIFY PHASE (judgment-day dual review)       │
│  Two independent judge agents review blindly    │
│  Both must PASS or fixes are applied            │
│  Max 2 iterations before escalation to user     │
└─────────────────────────────────────────────────┘
    ↓
  COMMIT → ARCHIVE → SAVE TO ENGRAM
```

---

## 2. Testing Strategy

### 2.1 Vitest — Backend & Logic (fast feedback)

**What to test:**
- Multi-tenant isolation (tenant A NEVER sees tenant B data)
- Prisma extensions (soft deletes filter correctly)
- Auth logic (JWT creation, validation, expiration, role checks)
- Zod schemas (accept valid, reject invalid, correct error codes)
- Financial calculations (transactions, reconciliations, balances)
- `response()` function (consistent output structure)
- `postRequest()` function (device metadata injection)
- API routes (against real test database, NOT mocks)

**Rules:**
- NEVER mock Prisma — use a real test database (`DATABASE_URL_TEST`)
- Each test file seeds its own data and cleans up after
- Test tenant isolation by creating 2 tenants and asserting cross-boundary queries return empty
- Use `pool: 'forks'` — MANDATORY when using AsyncLocalStorage
- Run: `rtk vitest run`

### 2.2 Playwright — E2E & UX (user verification)

**What to test:**
- Complete user flows (login → dashboard → action → result)
- Role-based access (admin sees X, volunteer sees Y)
- Tenant subdomain routing (correct tenant loads)
- Suspended tenant read-only mode (can view, cannot modify)
- Form validation (error messages appear, correct language)
- Mobile responsiveness (viewport testing)

**Rules:**
- Use Playwright MCP tools for agent-driven verification (`browser_navigate`, `browser_snapshot`, `browser_fill_form`)
- Write `.spec.ts` files for reproducible regression tests
- Test against `http://localhost:3000` with dev server running
- Seed test tenants before E2E suite runs
- Run: `rtk playwright test`

### 2.3 When Each Applies

| Scenario | Vitest | Playwright |
|----------|--------|------------|
| New API endpoint | ✅ Integration test | ❌ |
| New UI component | ❌ | ✅ Visual + interaction |
| Business logic change | ✅ Unit/integration | ✅ If user-facing |
| Bug fix | ✅ Regression test | ✅ If UI-related |
| Prisma schema change | ✅ Migration + isolation | ❌ |
| Auth/permission change | ✅ Logic test | ✅ Access control |
| Refactor | ✅ Existing tests pass | ✅ Existing tests pass |

---

## 3. Quality Gates per SDD Phase

| Phase | Gate | Fails if... |
|-------|------|-------------|
| **spec** | Scenarios complete | Missing GIVEN/WHEN/THEN for any requirement |
| **design** | Architecture sound | Violates base_requirements.md constraints |
| **tasks** | Test tasks included | No test task exists for the change |
| **apply** | TDD compliance | Code written before failing test |
| **apply** | Tests pass | `rtk vitest run` or `rtk playwright test` has failures |
| **apply** | TypeScript clean | `rtk tsc` has errors |
| **apply** | Lint clean | `rtk lint` has errors |
| **verify** | Spec compliance | Implementation diverges from spec scenarios |
| **verify** | E2E verification | Playwright MCP navigation reveals broken flows |
| **verify** | Tenant isolation | Cross-tenant data leak detected |
| **certify** | Dual review pass | Either judge reports CRITICAL issues |

---

## 4. Skill Lifecycle Management (CRITICAL)

**ALL skills are OFF by default.** Context pollution from unused skills degrades quality and wastes tokens.

### Activation Protocol

Before each task:
1. Identify which skills the task context requires (see map below)
2. Create symlinks: `ln -s ../../.agents/skills/<name> .claude/skills/<name>`
3. For user-level skills: they are already in `~/.claude/skills/` — invoke via Skill tool only when needed

After each task:
4. Remove ALL project symlinks: `rm -f .claude/skills/*`
5. Never leave skills active between tasks

### Skills Map

| Context | Activate (project) | Invoke (user-level) |
|---------|-------------------|---------------------|
| Writing tests | `test-driven-development`, `javascript-testing-patterns` | — |
| E2E tests | `e2e-testing-patterns` | — |
| React/Next.js code | `next-best-practices` | `vercel-react-best-practices` |
| Prisma schema/queries | `prisma-client-api`, `prisma-cli`, `prisma-database-setup` | `postgresql-table-design` |
| API endpoints | — | `error-handling-patterns` |
| UI pages (public) | — | `frontend-design` |
| UI pages (admin) | — | `interface-design` |
| Code review | — | `judgment-day` |
| Prompt/message design | — | `prompt-engineering-patterns` |

**Rule**: Multiple skills can apply simultaneously. Activate the MINIMUM set needed — never "just in case."

---

## 5. MCP Tools — When to Use

| MCP | When | Agent Phase |
|-----|------|-------------|
| **Playwright** | E2E testing, visual verification, form testing | apply, verify |
| **Prisma** | Schema migrations, database queries, data verification | apply, verify |
| **Railway** | Deploy to staging, check deployment status, logs | post-verify |
| **Sentry** | Check production errors, pull stack traces | monitoring |
| **Engram** | Save decisions, recover context, cross-session memory | ALL phases |
| **Linear** | Track issues, link PRs, update status | orchestrator |

---

## 6. Self-Correction Protocol

When a quality gate FAILS:

1. **Test failure** → Read error output → Write fix → Re-run tests → Max 3 attempts before escalating
2. **Type error** → Read `rtk tsc` output → Fix type → Re-check
3. **Lint error** → Run `rtk lint` → Auto-fix where possible → Manual fix remainder
4. **Verify failure** → Create new task for the gap → Re-enter apply phase for that task only
5. **Certify failure** → Apply judge feedback → Re-verify → Max 2 iterations before user escalation

**Escalation rule**: After 3 failed self-correction attempts on the same issue, STOP and ask the user. Save the failure context to Engram with type `bugfix` and tag `user-pending`.

---

## 7. Commands Reference

```bash
# Testing
rtk vitest run                    # Run all unit/integration tests
rtk vitest run src/lib/__tests__  # Run specific test directory
rtk playwright test               # Run all E2E tests
rtk playwright test --ui          # Run with Playwright UI

# Quality checks
rtk tsc                           # TypeScript compilation check
rtk lint                          # ESLint check
pnpm lint:fix                     # Auto-fix lint issues

# Development
pnpm dev                          # Start dev server (localhost:3000)
rtk prisma migrate dev            # Run migrations
rtk prisma db seed                # Seed database

# SDD (meta-commands via orchestrator)
/sdd-new <change>                 # Start new change (full pipeline)
/sdd-ff <change>                  # Fast-forward planning phases
/sdd-continue <change>            # Continue next phase
```

---

## 8. File Structure for Tests

```
src/
├── __tests__/                    # Vitest integration tests
│   ├── setup.ts                  # Test database setup/teardown
│   ├── helpers/                  # Test utilities (createTestTenant, etc.)
│   ├── api/                      # API route tests
│   │   ├── auth.test.ts
│   │   └── ...
│   ├── lib/                      # Library/utility tests
│   │   ├── tenantIsolation.test.ts
│   │   ├── softDelete.test.ts
│   │   └── auth.test.ts
│   └── validation/               # Zod schema tests
│       └── schemas.test.ts
├── e2e/                          # Playwright E2E tests
│   ├── fixtures/                 # Test data and page objects
│   │   ├── auth.fixture.ts
│   │   └── tenant.fixture.ts
│   ├── auth.spec.ts
│   ├── dashboard.spec.ts
│   ├── tenant-isolation.spec.ts
│   └── landing-cms.spec.ts
```

---

## 9. Non-Negotiable Principles

1. **No code without a test** — TDD is not optional. RED → GREEN → REFACTOR.
2. **No mock databases** — Integration tests hit real PostgreSQL. Mocks hide real bugs.
3. **No skipped quality gates** — Every phase must pass before the next begins.
4. **No manual verification when automated is possible** — If Playwright can check it, write a test.
5. **No context loss** — Every decision, bug, and discovery gets saved to Engram immediately.
6. **No silent failures** — If self-correction fails 3 times, escalate. Never loop infinitely.
7. **Specs are the source of truth** — Implementation matches specs, not the other way around.
