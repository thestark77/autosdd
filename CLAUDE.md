@AGENTS.md

# autoSDD — Self-Improving Autonomous Development Framework

Extension for gentle-ai. This project uses autoSDD to develop autoSDD (dogfooding).

## Stack

Markdown · Bash · PowerShell · Go (gentle-ai dependency)

## Read Before Coding

| Document | Purpose |
|----------|---------|
| `skill/SKILL.md` | **Core definition** — the framework itself (v5.0, must stay < 300 lines) |
| `context/audit-v4-prohuella.md` | Compliance audit that drove v4.1 and v5.0 improvements |
| `templates/CLAUDE.md` | Installed output template — must stay in sync with SKILL.md version |

## Critical Constraints

- All content (code, docs, commits) in **English**
- `skill/SKILL.md` must stay **under 300 lines** (currently 277)
- Changes to `skill/SKILL.md` must be reflected in **both installers** (`install.sh` + `install.ps1`)
- `templates/CLAUDE.md` must match the **current SKILL.md version** at all times
- **Never duplicate** what gentle-ai already provides (Engram, SDD phases, persona, model-assignments)
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

This project uses autoSDD to develop autoSDD. The audit report at `context/audit-v4-prohuella.md` documents the compliance issues that drove v4.1 and v5.0 improvements. Use `/audit` on autoSDD sessions to measure framework compliance.

---

<!-- autosdd:start -->
autoSDD v5.0 is the ACTIVE development framework. ALL prompts go through autoSDD unless opted out with `[raw]`, `[no-sdd]`, or `skip autosdd`.

### Core Rule
**The orchestrator DELEGATES. It never writes source code inline.** See `skill/SKILL.md` Section 1.

### Pipeline
Triage -> Route -> Plan (CREA prompt.md) -> Delegate (sub-agents with skill injection) -> Collect -> Close Version -> Knowledge Update -> Compaction Check

### Full Framework
Read: `skill/SKILL.md` (local, canonical) · `~/.claude/skills/autosdd/SKILL.md` (installed copy)

### Key Sections
- **Section 1**: Orchestrator identity (delegate, don't execute)
- **Section 3**: CREA applied ONCE on prompt.md
- **Section 4**: Sub-agent launch template (mandatory)
- **Section 5**: Skill routing (pattern match -> inject rules)

### Skills (orchestrator resolves automatically)
`prompt-engineering-patterns` · `frontend-design` · `interface-design` · `branch-pr` · `judgment-day` · `e2e-testing-patterns` · `error-handling-patterns` · `playwright-cli` · `claude-md-improver` · `feedback-report` · `knowledge-graph`

### SDD Phases (via gentle-ai)
`sdd-init` · `sdd-explore` · `sdd-propose` · `sdd-spec` · `sdd-design` · `sdd-tasks` · `sdd-apply` · `sdd-verify` · `sdd-archive` · `sdd-onboard`

### Context Files
- `context/audit-v4-prohuella.md` - Compliance audit history
- `context/questions.md` - Self-analysis protocol (v5.0 session audit prompt)
- `context/knowledge-vault/` - Architecture decisions, workflows, entities

### Tools
- **RTK**: ALWAYS prefix commands with `rtk` (60-90% token savings)
- **Monitor**: Event-driven waiting — NEVER sleep/poll

### Shared Protocols (managed by gentle-ai — do not duplicate)
| Protocol | File |
|----------|------|
| Persona | `~/.claude/skills/_shared/persona.md` |
| RTK | `~/.claude/skills/_shared/rtk.md` |
| SDD Orchestrator | `~/.claude/skills/_shared/sdd-orchestrator.md` |
| Engram Memory | `~/.claude/skills/_shared/engram-protocol.md` |
| Model Assignments | `~/.claude/skills/_shared/model-assignments.md` |
<!-- autosdd:end -->
