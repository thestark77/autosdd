@AGENTS.md

# [Project Name] — [Brief Description]

## Stack

[List your stack here]

## Read Before Coding

| Document | Purpose |
|----------|---------|
| `context/guidelines.md` | Technical conventions, patterns, security |
| `context/user_context.md` | User profile and preferences |
| `context/business_logic.md` | Domain knowledge and workflows |

## Agent Operational Freedom

- **LOCAL environment is yours**: DB, file system, dev server — use freely
- **Ask before guessing**: If a question would significantly improve results, ASK
- **Suggest improvements**: Proactively propose enhancements

<!-- autosdd:start -->
## autoSDD v5.3 — Active Pipeline (DO NOT REMOVE)

ALL prompts go through autoSDD unless `[raw]`, `[no-sdd]`, or `skip autosdd`.

### Core Rules
1. **DELEGATE** — never write 2+ files inline. Read SKILL.md Section 1.
2. **VERSION FIRST** — before planning, create `context/appVersions/vX.Y.Z/` + save `original_prompt.md`
3. **PROGRESS.md is sacred** — update at every step. It's your compaction survival anchor.
4. **Feedback after every task** — ask user ≥1 strategic question. Persist answers.

### Pipeline
`VERSION INIT → TRIAGE → ROUTE → PLAN (CREA) → DELEGATE → COLLECT → CLOSE → KNOWLEDGE UPDATE`

### Routing (if X → use Y skill)
| Context | Skill |
|---------|-------|
| Public UI (.tsx/.vue pages) | `frontend-design` |
| Admin/dashboard UI | `interface-design` |
| API routes, validation | `error-handling-patterns` |
| DB schema, .prisma | `postgresql-table-design` |
| Tests (.test., .spec.) | `e2e-testing-patterns` |
| Browser automation | `playwright-cli` (ALWAYS --headed) |
| PR creation | `branch-pr` |
| Security, 5+ files | `judgment-day` |

**Screenshots**: ALL Playwright captures → `context/appVersions/vX.Y.Z/screenshots/` (current version). Never elsewhere.

### Knowledge Caching (saves tokens)
Before reading 4+ files → check Engram `knowledge/{project}/{topic}` for cached maps.
After understanding a flow → save a 20-line map to Engram.

### Compaction Recovery (read this AFTER any compaction)
1. Read `PROGRESS.md` (ONLY this — your state anchor)
2. Read current version's `prompt.md` (your plan)
3. `mem_context()` + `mem_search("session/{project}")`
4. Resume from PROGRESS.md state — do NOT read other files unless PROGRESS.md says you need them

### Hooks
- **SubagentStop**: Update PROGRESS.md + save observation + check feedback debt
- **PreCompact**: Save ALL state to PROGRESS.md + Engram NOW (compaction imminent)
- **Stop**: Check feedback.md generated + PROGRESS.md current
- **UserPromptSubmit**: Reset stop-hook debounce

### gentle-ai (optional foundation)
Provides: Engram MCP · SDD phases · persona · model-assignments · branch-pr · judgment-day
autoSDD works without it (degraded mode).

Read full framework: `~/.claude/skills/autosdd/SKILL.md`
<!-- autosdd:end -->
