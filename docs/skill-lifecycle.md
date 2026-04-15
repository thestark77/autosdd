# Skill Lifecycle Management

Skills are focused instruction sets that the AI reads before performing specific tasks. They provide domain expertise without polluting the main context.

## The Golden Rule

**ALL skills are OFF by default.**

Unused skills waste tokens on every request, degrade response quality by diluting focus, and increase costs. The skill system only works if you maintain strict discipline about activation and deactivation.

---

## How Skills Work

Skills are Markdown files stored in two locations:

| Location | Scope | Purpose |
|----------|-------|---------|
| `.agents/skills/` | Project-level | Project-specific patterns and conventions |
| `~/.claude/skills/` | User-level | Cross-project expertise |

Claude Code reads skills from `.claude/skills/` in the project root. You activate a project-level skill by creating a symlink there.

---

## Activation Protocol

### Before Each Task

1. Identify which skills apply to the task (use the map below)
2. Activate project-level skills via symlink:
   ```bash
   ln -s ../../.agents/skills/test-driven-development .claude/skills/test-driven-development
   ln -s ../../.agents/skills/javascript-testing-patterns .claude/skills/javascript-testing-patterns
   ```
3. User-level skills in `~/.claude/skills/` are pre-loaded — invoke them via the Skill tool when needed

### After Each Task

4. Remove ALL project symlinks:
   ```bash
   rm -f .claude/skills/*
   ```
5. Verify deactivation — run `ls .claude/skills/` to confirm empty

**Never leave skills active between tasks.** This is not optional.

---

## Skills Map

| Task Context | Activate (project `.agents/skills/`) | Invoke (user `~/.claude/skills/`) |
|-------------|--------------------------------------|----------------------------------|
| Writing any tests | `test-driven-development`, `javascript-testing-patterns` | — |
| Playwright E2E tests | `e2e-testing-patterns` | — |
| React components | `next-best-practices` | `vercel-react-best-practices` |
| Next.js routes/pages | `next-best-practices` | `vercel-react-best-practices` |
| Prisma schema design | `prisma-client-api`, `prisma-database-setup` | `postgresql-table-design` |
| Prisma queries/CRUD | `prisma-client-api`, `prisma-cli` | — |
| API endpoint design | — | `error-handling-patterns` |
| Public landing pages | — | `frontend-design` |
| Admin dashboards | — | `interface-design` |
| Code review | — | `judgment-day` |
| Prompt/voice input | — | `prompt-engineering-patterns` |
| PR creation | — | `branch-pr` |
| GitHub issues | — | `issue-creation` |

### Combining Skills

Multiple skills can — and should — be active simultaneously when a task spans multiple contexts:

```bash
# Writing an API endpoint with tests
ln -s ../../.agents/skills/test-driven-development .claude/skills/test-driven-development
ln -s ../../.agents/skills/javascript-testing-patterns .claude/skills/javascript-testing-patterns
ln -s ../../.agents/skills/prisma-client-api .claude/skills/prisma-client-api
# user-level: error-handling-patterns (invoked via Skill tool when needed)
```

The rule is minimum set, not single skill. If the task genuinely needs 3 skills, use 3.

---

## Installing Skills

### Via gentle-ai (recommended)

```bash
gentle-ai skills install test-driven-development
gentle-ai skills install javascript-testing-patterns
```

### Via npx

```bash
npx -y skills add test-driven-development
npx -y skills add javascript-testing-patterns
```

### Manual

Copy the skill's `SKILL.md` into `.agents/skills/<name>/SKILL.md`.

---

## Available Skills

### Project-Level Skills

These ship with AutoSDD or can be installed via gentle-ai:

| Skill | Description |
|-------|-------------|
| `test-driven-development` | TDD methodology, RED-GREEN-REFACTOR discipline |
| `javascript-testing-patterns` | Vitest patterns, test setup, async testing |
| `e2e-testing-patterns` | Playwright patterns, fixtures, page objects |
| `next-best-practices` | Next.js App Router, RSC, Server Actions |
| `prisma-client-api` | Prisma query API, relations, transactions |
| `prisma-cli` | Migrations, db push, generate, seed |
| `prisma-database-setup` | Connection config, pooling, multi-env |

### User-Level Skills

Install these globally once, available across all projects:

| Skill | Description |
|-------|-------------|
| `vercel-react-best-practices` | React performance, memoization, hydration |
| `postgresql-table-design` | Schema design, indexing, constraints |
| `error-handling-patterns` | API errors, Result types, resilience |
| `frontend-design` | Public UI, landing pages, marketing |
| `interface-design` | Dashboards, admin panels, data-heavy UI |
| `prompt-engineering-patterns` | Prompt design, voice input, structured output |
| `judgment-day` | Dual adversarial review protocol |
| `branch-pr` | PR creation with issue linking |
| `issue-creation` | GitHub issue templates |

---

## Agent Context Impact

Each active skill adds its full content to every agent request. A 5KB skill file = 5KB × every request in the session. For a 50-message session, that is 250KB of extra tokens — for a skill that might only be relevant to 2 of those messages.

This is why deactivation matters. The cost is not just money — it is response quality. An agent reading 6 irrelevant skills has less capacity to focus on the actual task.

---

## Skill Registry

AutoSDD maintains a skill registry at `.atl/skill-registry.md` (or in Engram). The orchestrator reads this registry once per session and injects matching compact rules into sub-agent prompts. Sub-agents never read skill files directly — they receive pre-digested rules from the orchestrator.

This is the compaction-safe design: even if the orchestrator loses context, it re-reads the registry on the next delegation.
