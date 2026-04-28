@AGENTS.md

# autoSDD — Self-Improving Autonomous Development Framework

Extension for gentle-ai. This project uses autoSDD to develop autoSDD (dogfooding).

## Stack

Markdown · Bash · PowerShell · Go (gentle-ai dependency)

## Read Before Coding

| Document | Purpose |
|----------|---------|
| `skill/SKILL.md` | **Core definition** — the framework itself (v5.1, must stay < 300 lines) |
| `context/audit-v4-prohuella.md` | Compliance audit that drove v4.1 and v5.0 improvements |
| `templates/CLAUDE.md` | Installed output template — must stay in sync with SKILL.md version |

## Critical Constraints

- All content (code, docs, commits) in **English**
- `skill/SKILL.md` must stay **under 300 lines** (currently 299)
- Changes to `skill/SKILL.md` must be reflected in **both installers** (`install.sh` + `install.ps1`)
- `templates/CLAUDE.md` must match the **current SKILL.md version** at all times
- **Never duplicate** what gentle-ai already provides (Engram, SDD phases, persona, model-assignments)
- No global CHANGELOG.md — changelogs live per-version in `context/appVersions/vX.Y.Z/changelog.md`
- Adding/removing a skill requires updating ALL of:
  - `skill/SKILL.md` Section 5 (routing table) + Section 11 (ecosystem list)
  - `install.sh` + `install.ps1`
  - `README.md`
  - `templates/CLAUDE.md` (skills list in the autoSDD block)

## Testing

After any `skill/SKILL.md` change:
- Verify section count (11 sections) and line count (< 300)
- Verify `templates/CLAUDE.md` version string matches

After installer changes:
- Dry-run both: `bash install.sh --dry-run` and `pwsh install.ps1 -DryRun`

After template changes:
- Verify autoSDD block version matches current `skill/SKILL.md` frontmatter version

## Dogfooding

This project uses autoSDD to develop autoSDD. The audit report at `context/audit-v4-prohuella.md` documents the compliance issues that drove v4.1 and v5.0 improvements.

- `/audit` — post-hoc JSONL analysis of session compliance
- `/self-analysis` — in-session self-audit against v5.1 checkpoints (see `context/questions.md`)
- `/improve` — aggregate telemetry across sessions, propose SKILL.md changes

---

<!-- autosdd:start -->
## autoSDD v5.2 — Active Pipeline (DO NOT REMOVE)

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
