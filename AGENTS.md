# autoSDD — Architecture & Structure Guide

> This document defines autoSDD's architecture. ALL modifications MUST follow these patterns.

## Project Type

Framework (methodology layer on gentle-ai). NOT an application.
Outputs: skills, templates, installers, shared protocols.

autoSDD extends gentle-ai with: meta-pipeline (triage/route/plan/delegate/collect/close), CREA prompt structure, telemetry (/audit, /improve, /self-analysis), bidirectional feedback, RTK optimization, and active feedback collection.

gentle-ai = infrastructure. autoSDD = methodology + continuous self-improvement.

---

## File Structure (canonical — additions require updating this doc)

```
autosdd/
├── CLAUDE.md                          # Project config + autoSDD active block (references @AGENTS.md)
├── AGENTS.md                          # This file — architecture reference for all agents
├── README.md                          # Public documentation
├── LEARNING.md                        # Promoted rules from /improve cycles
├── CHANGELOG.md                       # Release history
├── install.sh                         # One-command installer (macOS/Linux)
├── install.ps1                        # One-command installer (Windows PowerShell)
│
├── skill/
│   └── SKILL.md                       # Core framework definition (≤300 lines, MUST stay under limit)
│                                      # Installed to: ~/.{agent}/skills/autosdd/SKILL.md
│
├── skills/                            # autoSDD-owned bundled skills
│   ├── autosdd-telemetry/SKILL.md     # /audit, /improve, /self-analysis — compliance scoring
│   ├── feedback-report/SKILL.md       # /feedback [timerange] — time-based reports
│   └── knowledge-graph/SKILL.md       # /knowledge-graph — Engram visualization
│                                      # All installed to: ~/.{agent}/skills/{skill-name}/
│
├── shared/                            # Shared protocols (installed to ~/.{agent}/skills/_shared/)
│   ├── rtk.md                         # RTK token optimization — autoSDD OWNS this
│   ├── persona.md                     # Agent persona and rules — gentle-ai origin
│   ├── sdd-orchestrator.md            # SDD delegation and sub-agent protocol — gentle-ai origin
│   ├── engram-protocol.md             # Engram memory protocol — gentle-ai origin
│   └── model-assignments.md           # Phase → model mapping — gentle-ai origin
│
├── templates/                         # Project bootstrap templates (copied to target project on install)
│   ├── CLAUDE.md                      # Slim index template — SOURCE OF TRUTH for installed CLAUDE.md
│   ├── autosdd.md                     # Framework reference card
│   ├── guidelines.md                  # Technical rules template
│   ├── user_context.md                # User profile template
│   ├── business_logic.md              # Domain knowledge template
│   └── knowledge-graph.html           # Standalone graph viewer
│
├── scripts/
│   ├── auto-resume.sh                 # Rate-limit recovery wrapper (macOS/Linux)
│   └── auto-resume.ps1                # Rate-limit recovery wrapper (Windows)
│
├── patches/
│   └── engram-embedding.patch         # Patch for Engram MCP embedding layer
│
├── context/                           # Project-level context (dogfooding — autoSDD developing autoSDD)
│   ├── guidelines.md                  # autoSDD project conventions
│   ├── user_context.md                # Developer profile
│   ├── business_logic.md              # Framework domain rules
│   ├── autosdd.md                     # Framework reference (local copy)
│   ├── audit-v4-prohuella.md          # Compliance audit that drove v4.1 and v5.0 improvements
│   ├── questions.md                   # /self-analysis checkpoint questions
│   ├── knowledge-graph.html           # Local memory visualization
│   ├── knowledge-graph.json           # Graph data export
│   ├── knowledge-graph-data.js        # Graph data (JS module format)
│   └── knowledge-vault/               # Structured memory artifacts
│       ├── _index.md                  # Vault index
│       ├── user-profile.md            # Persisted user profile
│       ├── architecture/              # Architecture decisions
│       ├── decisions/                 # Key decisions log
│       ├── entities/                  # Domain entities
│       ├── guidelines/                # Promoted guidelines
│       ├── versions/                  # Version history artifacts
│       └── workflows/                 # Workflow documentation
│
├── docs/
│   ├── testing-strategy.md            # TDD guide for autoSDD projects
│   ├── skill-lifecycle.md             # Skill activation protocol
│   ├── hooks.md                       # Claude Code hooks reference
│   ├── mcp-setup.md                   # MCP configuration guide
│   └── iron-man-roadmap.md            # Voice/mobile vision
│
└── .claude/
    ├── settings.json                  # Hook definitions deployed to project by installer
    └── hooks/                         # Hook script directory
```

---

## Architecture Principles

1. **Installers are the distribution mechanism** — `templates/CLAUDE.md` is the source of truth for what gets installed into target projects. The installers (`install.sh`, `install.ps1`) embed and deploy it. Manual edits to a project's `CLAUDE.md` are NOT the distribution path — changes must go into `templates/CLAUDE.md` first.

2. **Core behaviors enforced structurally** — Pipeline gates, hooks, and scripts enforce compliance. Text-only instructions are insufficient. Any MANDATORY behavior MUST have a structural enforcement mechanism: a Claude Code hook (in `.claude/settings.json`), a validation gate defined in SKILL.md, or an installer-deployed script. If it is not enforced, it is a suggestion.

3. **Orchestrator delegates, never executes** — The orchestrator never writes source files (`.ts`, `.tsx`, `.prisma`, `.css`, `.py`, `.go`, `.sh`, `.ps1`) inline. ALL source file changes go through sub-agents. The only inline exceptions: writing `prompt.md`, `feedback.md`, `PROGRESS.md`; git commands; reading 1-3 files; single-line mechanical edits (version bump, import typo).

4. **SKILL.md stays under 300 lines** — Brevity is structurally enforced. Overflow goes to separate skills (`skills/`) or shared protocols (`shared/`). After any change, verify with a line count.

5. **Single source of truth** — Each piece of information lives in ONE place. Changes propagate via documented sync paths (see below). The most common violation is duplicating the skills list — update the table in one file, then sync to the rest via the sync paths.

6. **No absolute paths in distributable files** — All paths in installers, templates, skills, and shared protocols MUST be relative to the project or use `~/` home-directory references. Machine-specific paths like `C:\Users\...` or `/home/...` are forbidden in anything distributed.

7. **gentle-ai decoupling** — autoSDD operates independently of gentle-ai. If gentle-ai is missing or outdated, autoSDD degrades gracefully (WARN + continue). Never import gentle-ai internals or rely on its internal file structure. Shared protocols (`persona.md`, `engram-protocol.md`, etc.) are optional enhancements.

---

## Sync Paths (MANDATORY — follow when changing any source)

These chains must be kept in sync manually. When you change any file in the left column, update everything to the right.

### Version bump (SKILL.md frontmatter)
```
skill/SKILL.md (version field)
  → templates/CLAUDE.md (autoSDD block version string)
  → install.sh (AUTOSDD_BLOCK embedded version string)
  → install.ps1 (AUTOSDD_BLOCK embedded version string)
```

### autoSDD block content change (ecosystem table, pipeline, etc.)
```
templates/CLAUDE.md (<!-- autosdd:start --> ... <!-- autosdd:end -->)
  → install.sh (AUTOSDD_BLOCK heredoc)
  → install.ps1 (AUTOSDD_BLOCK here-string)
  → CLAUDE.md (project's own autosdd block — dogfooding sync)
```

### Adding or removing a skill
```
skill/SKILL.md Section 5 (routing table) + Section 11 (ecosystem list)
  → skill/SKILL.md Section 11 installer list
  → install.sh (skill install commands)
  → install.ps1 (skill install commands)
  → README.md (What Gets Installed table)
  → templates/CLAUDE.md (Skills installed by autoSDD table)
  → CLAUDE.md (project dogfooding autoSDD block)
```

### Hook changes
```
.claude/settings.json (hook definitions)
  → install.sh (hooks deployment section)
  → install.ps1 (hooks deployment section)
  → docs/hooks.md (documentation)
```

### Shared protocol changes (rtk.md — autoSDD-owned)
```
shared/rtk.md
  → install.sh (shared/ copy commands)
  → install.ps1 (shared/ copy commands)
```

### README.md (MANDATORY — update on ANY user-visible change)
```
README.md must be updated when ANY of these change:
  - skill/SKILL.md (pipeline steps, features, non-negotiable principles)
  - skills/ (add/remove bundled skill — also in "Adding a skill" path above)
  - .claude/settings.json (hooks — Pipeline Gates & Hooks section)
  - templates/ (file structure, installation output)
  - install.sh / install.ps1 (installation steps, prerequisites)
  - docs/ (file structure)
README.md sections to check: How It Works · Pipeline Gates & Hooks · Commands · File Structure · What Gets Installed · Non-Negotiable Principles
```

---

## Enforcement Mechanisms

| What | How | Where |
|------|-----|-------|
| Step 5 checkpoint (observation + feedback) | SubagentStop hook → prompt injected after every sub-agent | `.claude/settings.json` |
| Step 8 pre-compaction save | PreCompact hook → prompt injected before context compaction | `.claude/settings.json` |
| Pre-close checkpoint | Stop hook → non-blocking prompt before session end | `.claude/settings.json` |
| Pre-launch gate (G2) | Inline checkpoint in SKILL.md Step 4 — verify all 6 template sections | `skill/SKILL.md` Section 4 |
| Pipeline gates G1-G4 | Documented with MANDATORY tag in CLAUDE.md + templates/CLAUDE.md | `templates/CLAUDE.md` |
| Feedback collection | MANDATORY tag + NON-COMPLIANT consequence in SKILL.md Step 6 | `skill/SKILL.md` Section 9 |
| SKILL.md line limit (300) | Manual verification after edits; documented in CLAUDE.md Testing section | `CLAUDE.md` |
| Version string sync | Manual verification after SKILL.md version bump | `CLAUDE.md` Testing section |
| Installer dry-run | `bash install.sh --dry-run` and `pwsh install.ps1 -DryRun` | CI / manual |

---

## Skill Registry

### Skills owned and installed by autoSDD

| Skill | Source | Trigger |
|-------|--------|---------|
| `autosdd` | `skill/SKILL.md` → `~/.claude/skills/autosdd/` | ALWAYS ACTIVE |
| `autosdd-telemetry` | `skills/autosdd-telemetry/SKILL.md` | `/audit`, `/improve`, `/self-analysis` |
| `feedback-report` | `skills/feedback-report/SKILL.md` | `/feedback [timerange]` |
| `knowledge-graph` | `skills/knowledge-graph/SKILL.md` | `/knowledge-graph` |
| `prompt-engineering-patterns` | Fetched from upstream on install | Every CREA prompt.md build |
| `frontend-design` | Fetched from upstream on install | `.tsx` pages (public-facing) |
| `interface-design` | Fetched from upstream on install | `.tsx` pages (admin/dashboard) |
| `e2e-testing-patterns` | Fetched from upstream on install | `.test.`, `.spec.`, E2E |
| `error-handling-patterns` | Fetched from upstream on install | `route.ts`, `/api/`, validation |
| `playwright-cli` | Fetched from upstream on install | Browser automation (ALWAYS `--headed`) |
| `claude-md-improver` | Fetched from upstream on install | `CLAUDE.md` edits |

### Skills provided by gentle-ai (DO NOT reinstall)

| Skill | Trigger |
|-------|---------|
| `branch-pr` | PR creation, shipping |
| `judgment-day` | Security, finance, 5+ files — parallel adversarial review |
| `skill-creator` | Creating new skills |
| `issue-creation` | Issue creation workflow |
| `skill-registry` | Skill registry management |
| `go-testing` | Go tests, Bubbletea |

### SDD Phase Skills (via gentle-ai)

`sdd-init` · `sdd-explore` · `sdd-propose` · `sdd-spec` · `sdd-design` · `sdd-tasks` · `sdd-apply` · `sdd-verify` · `sdd-archive` · `sdd-onboard`

---

## Shared Protocols

| Protocol | File | Owner | Description |
|----------|------|-------|-------------|
| RTK Token Optimization | `shared/rtk.md` → `~/.claude/skills/_shared/rtk.md` | **autoSDD** | Always prefix commands with `rtk`. 60-90% token savings. |
| Persona & Rules | `shared/persona.md` → `~/.claude/skills/_shared/persona.md` | gentle-ai origin | Agent persona, language rules, operating rules |
| SDD Orchestrator | `shared/sdd-orchestrator.md` → `~/.claude/skills/_shared/sdd-orchestrator.md` | gentle-ai origin | SDD delegation and sub-agent protocol |
| Engram Memory | `shared/engram-protocol.md` → `~/.claude/skills/_shared/engram-protocol.md` | gentle-ai origin | Persistent cross-session memory protocol |
| Model Assignments | `shared/model-assignments.md` → `~/.claude/skills/_shared/model-assignments.md` | gentle-ai origin | Phase → model (sonnet/opus) mapping |

autoSDD owns ONLY `rtk.md`. The other four protocols originate in gentle-ai; autoSDD ships local copies so the installer can deploy them without requiring gentle-ai. Do NOT modify their content to diverge from the gentle-ai originals.

---

## Testing & Validation

### After any `skill/SKILL.md` change
- Verify section count: must have exactly 11 sections
- Verify line count: must be under 300 lines
- Verify `templates/CLAUDE.md` version string matches the SKILL.md frontmatter `version` field

### After installer changes
```bash
bash install.sh --dry-run
pwsh install.ps1 -DryRun
```

### After `templates/CLAUDE.md` changes
- Verify the autoSDD block version string matches the current `skill/SKILL.md` frontmatter version
- Verify the skills table matches `skill/SKILL.md` Section 11

### After adding or removing a skill
- Run full sync path (see Sync Paths above) — all 5 files must be updated before committing

### After hook changes
- Verify `.claude/settings.json` hook prompts reference correct SKILL.md step numbers
- Verify installer deploys the updated settings.json

### After ANY user-visible change (pipeline, features, hooks, skills, file structure)
- Update `README.md` — see README sync path for which sections to check

---

## No Absolute Paths

All paths in distributable files (installers, templates, `skill/SKILL.md`, `skills/*/SKILL.md`, `shared/*.md`) MUST be:
- Relative to the project root, OR
- Home-relative using `~/` (e.g., `~/.claude/skills/autosdd/SKILL.md`)

NEVER hardcode machine-specific paths such as `C:\Users\sebas\...` or `/home/username/...` in any distributable file. This repository is installed on machines with different usernames and OS layouts.
