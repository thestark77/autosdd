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
- **Stop**: pre-close checkpoint with debounce (fires once per user interaction, resets on next user message)
- **UserPromptSubmit**: resets Stop hook debounce marker

### Shared Protocols (gentle-ai owns _shared/, autoSDD adds rtk.md only)
| Protocol | File |
|----------|------|
| RTK Token Optimization | `~/.claude/skills/_shared/rtk.md` |
| Persona & Rules | `~/.claude/skills/_shared/persona.md` (gentle-ai) |
| SDD Orchestrator | `~/.claude/skills/_shared/sdd-orchestrator.md` (gentle-ai) |
| Engram Memory | `~/.claude/skills/_shared/engram-protocol.md` (gentle-ai) |

Read the full framework: `~/.claude/skills/autosdd/SKILL.md`
<!-- autosdd:end -->
