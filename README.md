# AutoSDD v5 — Self-Improving Autonomous Development

<div align="center">

**AI doesn't replace your ability to think — it AMPLIFIES it.**<br>
**That's what separates a developer who USES AI from one who DEPENDS on it.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-blue)](https://claude.ai/claude-code)
[![gentle-ai](https://img.shields.io/badge/gentle--ai-FUNDAMENTAL-red)](https://github.com/Gentleman-Programming/gentle-ai)
[![RTK](https://img.shields.io/badge/RTK-Token%20Killer-orange)](https://github.com/rtk-ai/rtk)
[![Made by Gentleman Programming](https://img.shields.io/badge/Made%20by-Gentleman%20Programming-blueviolet)](https://github.com/Gentleman-Programming)

</div>

---

## What Is autoSDD?

autoSDD is a **methodology layer** on top of [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai). gentle-ai provides the infrastructure (skills, MCPs, agents). autoSDD provides the process.

**v5 adds telemetry and self-improvement**: the framework measures its own compliance and actively improves. Every session can be audited, every version gets telemetry metrics, and the orchestrator delegates all code to sub-agents — never writes inline.

### What autoSDD Adds

- **4 Flows** — DEV, DEBUG, REVIEW, RESEARCH (self-improvement absorbed into telemetry)
- **CREA Framework** — applied ONCE on prompt.md (not on every individual prompt)
- **Telemetry** — `/audit` and `/improve` commands measure and improve framework compliance
- **Active Feedback Collection** — non-blocking questions after UI, features, refactors, and design decisions
- **Bidirectional Feedback** — AI→User prompt coaching + User→AI preference learning, persisted across sessions
- **Orchestrator-First** — delegates ALL code to sub-agents, never writes source code inline
- **Event-Driven** — Monitor tool for all waiting, never sleep or polling loops

---

## How It Works

Every user prompt flows through this pipeline:

1. **TRIAGE** — Is the prompt clear? Assign HIGH/MEDIUM/LOW. Check Engram for pending tasks and learnings.
2. **ROUTE** — Detect intent: feature→DEV, fix→DEBUG, review→REVIEW, research→RESEARCH.
3. **PLAN (CREA)** — Build `prompt.md` with full CREA structure (Context, Role, Specificity, Action).
4. **DELEGATE** — Launch sub-agents with skill injection using the mandatory launch template. Pre-launch gate verifies all 6 template sections.
5. **COLLECT** — Gather results, validate output, fix failures by re-delegating (never inline). Save observation + ask user feedback.
6. **CLOSE VERSION** — Generate `feedback.md` with telemetry metrics, update `PROGRESS.md`.
7. **KNOWLEDGE UPDATE** — Update context files, save to Engram memory.
8. **COMPACTION CHECK** — At >50% context window, suggest `/compact` after persisting state to Engram.

**Mid-Pipeline Interrupt**: If the user sends a new message during execution, the orchestrator: (1) answers any question FIRST, (2) re-prioritizes the full task queue, (3) checks if completed work needs rework, (4) resumes from the updated queue.

### Development Flow

PROMPT REFINE → INTAKE → PLAN (explore → propose → spec → design → tasks) → BUILD (TDD: RED → GREEN → REFACTOR) → VERIFY → CERTIFY (judgment-day) → SHIP → REVIEW

### Debug Flow

REPRODUCE → DIAGNOSE → FIX (TDD) → VERIFY → DOCUMENT

### Code Review Flow

INGEST → ANALYZE (6 agents + judgment-day in parallel) → REPORT → FIX (optional)

### Research Flow

SCOPE → GATHER → EVALUATE (scoring matrix) → SYNTHESIZE → DECIDE

---

## Bidirectional Feedback (v5)

### AI → User

The AI proactively identifies weaknesses in your prompts and educates you:

- **Missing context**: "You didn't mention which auth pattern to follow"
- **Architecture gaps**: "This violates the repository pattern in your guidelines"
- **Security blind spots**: "No input validation mentioned for user data"
- **Skill gaps**: "You consistently skip database normalization — here's how to improve"
- **Token waste**: "3 debug cycles could have been avoided with clearer error reproduction steps"

At version close, a `feedback.md` report is auto-generated with all findings and telemetry metrics.

### User → AI

When you correct the AI, it persists the lesson:

- Technical corrections → `context/guidelines.md` + Engram
- Style preferences → `context/user_context.md` + Engram
- Agent errors → Engram (evaluated for SKILL.md updates if systemic)

The AI confirms: "Anotado. Guardé que [X]. No va a pasar de nuevo."

### v5 Enhancements

- **Active feedback**: the orchestrator asks non-blocking questions after every UI change, new feature, refactor, or design decision — feedback is collected without blocking execution
- **TODO list review**: TODO lists are checked at triage, collect, and close phases to ensure nothing is missed
- **Session observations**: compliance notes saved to Engram at each pipeline step — feeds `/improve` across sessions
- **Tiered knowledge**: observations → consolidated learnings → promoted rules (SKILL.md permanent changes)

---

## Pipeline Gates & Hooks (v5)

### Pipeline Gates (MANDATORY — verified before each phase transition)

| Gate | Before... | Verifies |
|------|-----------|----------|
| G1 | Planning | Engram searched for pending tasks + learnings |
| G2 | Delegating | prompt.md has CREA, launch template filled (all 6 sections), `model` set, skills as TEXT |
| G3 | Collecting | Observation saved for each delegation, ≥1 feedback question asked |
| G4 | Closing | feedback.md generated, user feedback persisted, Engram summary saved |

### Structural Enforcement (Claude Code Hooks)

The installer deploys `.claude/settings.json` with hooks that trigger at key pipeline moments:

| Hook | Trigger | Action |
|------|---------|--------|
| **SubagentStop** | After every sub-agent completes | Run Step 5 checkpoint (save observation, check feedback debt) |
| **PreCompact** | Before context compaction | Run Step 8 (save Engram summary, persist plan state) |
| **Stop** | Before session ends | Pre-close checkpoint: feedback.md + README/CHANGELOG sync (non-blocking) |

Core behaviors are enforced structurally (hooks, gates, scripts) — not just text suggestions.

### Commands

| Command | What it does |
|---------|-------------|
| `/feedback` | Show feedback for last completed version |
| `/feedback week` | Aggregate feedback for last 7 days |
| `/feedback month` | Aggregate feedback for last 30 days |
| `/feedback v1.0..v2.0` | Feedback for a specific version range |
| `/audit [session-id\|last\|last-N]` | Analyze session for autoSDD compliance |
| `/improve [target]` | Run audit + generate improvement plan |
| `/self-analysis` | In-session self-audit vs v5.1 checkpoints |
| `/knowledge-graph` | Visualize AI's memory as interactive graph |
| `/knowledge-graph obsidian` | Export as Obsidian vault with wikilinks |
| `/knowledge-graph stats` | Memory statistics summary |

---

## Installation (One Command)

### Prerequisites

You only need a **package manager**:

| OS | Install |
|----|---------|
| macOS / Linux | [Homebrew](https://brew.sh): `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| Windows | [Scoop](https://scoop.sh): `irm get.scoop.sh \| iex` |

### Install

> Run from inside your project directory. The installer bootstraps templates into the current folder.

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/thestark77/autosdd/main/install.ps1 | iex
```

The installer asks 2 questions (which AI agents? response style?) and handles everything else:

1. Installs **Node.js + Go** (via brew/scoop)
2. Installs **gentle-ai** (SDD skills, Engram, Context7)
3. Installs **14 core skills** globally (from original sources)
4. Installs **shared protocols** (persona, RTK, orchestrator, engram, model assignments)
5. Installs **RTK** (token optimization — 60-90% savings)
6. Installs **auto-resume** (rate-limit recovery wrapper — default ON)
7. Bootstraps **project templates** (context/ + CLAUDE.md)

### After Installation

```bash
/sdd-init          # Detects stack, creates context files, configures SDD
/sdd-new feature   # Start building
```

### Manual Install

```bash
gentle-ai install --preset full-gentleman --sdd-mode multi

mkdir -p ~/.claude/skills/autosdd
curl -o ~/.claude/skills/autosdd/SKILL.md \
  https://raw.githubusercontent.com/thestark77/autosdd/main/skill/SKILL.md
```

---

## What Gets Installed

### Auto-installed by autoSDD

| Component | Purpose |
|-----------|---------|
| `autosdd` skill | This framework — flow router, CREA, feedback engine, telemetry |
| `autosdd-telemetry` skill | Session auditing, compliance scoring, /audit, /improve, /self-analysis |
| `prompt-engineering-patterns` | CREA prompt techniques (CoT, Few-Shot, Structured Output) |
| `frontend-design` | Production-grade frontend interfaces |
| `interface-design` | Dashboards, admin panels, internal tools |
| `claude-md-improver` | CLAUDE.md audit and improvement |
| `e2e-testing-patterns` | E2E testing with Playwright/Cypress |
| `error-handling-patterns` | Error handling across languages |
| `playwright-cli` | Browser automation and testing (ALWAYS `--headed`) |
| `feedback-report` | Time-based feedback reports |
| `knowledge-graph` | Memory visualization as graph |
| Shared protocols (5) | RTK (autoSDD-owned) + persona, orchestrator, engram, model-assignments (gentle-ai copies) |
| `.claude/settings.json` | Pipeline enforcement hooks (SubagentStop, PreCompact, Stop) |

### Auto-installed by gentle-ai

| Component | Purpose |
|-----------|---------|
| SDD skills (10) | sdd-init, explore, propose, spec, design, tasks, apply, verify, archive, onboard |
| `branch-pr` | PR creation workflow with issue-first enforcement |
| `judgment-day` | Parallel adversarial code review (two blind judges) |
| `skill-creator` | Create new skills |
| `issue-creation` | Issue creation workflow |
| `skill-registry` | Skill registry management |
| Engram MCP | Persistent cross-session memory |
| Context7 MCP | Live library/framework documentation |
| RTK | Token-optimized CLI output |
| auto-resume | Rate-limit recovery — wraps `claude` CLI, auto-waits and resumes on rate limits |

### Recommended (not auto-installed)

| Tool | Purpose | Install |
|------|---------|---------|
| TypeScript LSP | Go-to-definition for TS projects | Plugin: `typescript-lsp` |
| code-review | Automated PR review | Plugin: `code-review` |
| claude-powerline | Status line | `npx -y @owloops/claude-powerline@latest` |

---

## Use Cases

**Build a feature**: "Add user registration with email verification" → DEV flow → explore → propose → spec → design → tasks → apply (TDD) → verify → ship

**Fix a bug**: "Login fails with 500 on mobile" → DEBUG flow → reproduce → diagnose → fix (TDD) → verify → document

**Review code**: "Review PR #45" → REVIEW flow → analyze (parallel judges) → report → fix (optional)

**Research**: "Should we migrate from REST to tRPC?" → RESEARCH flow → gather → evaluate → synthesize → decide

**Get feedback**: `/feedback week` → aggregate report of prompt quality, skill gaps, token waste, recommendations

**Audit compliance**: `/audit last` → analyze last session for autoSDD compliance violations and improvement opportunities

**See AI's memory**: `/knowledge-graph` → interactive D3.js graph of all decisions, conventions, entities, and relationships

---

## File Structure

```
autosdd/
├── CLAUDE.md                      # Project config + autoSDD active block
├── AGENTS.md                      # Architecture reference — ALL modifications follow this
├── README.md                      # Public documentation
├── LEARNING.md                    # Promoted rules from /improve cycles
├── CHANGELOG.md                   # Release history
├── install.sh / install.ps1      # One-command installers (distribution mechanism)
├── skill/
│   └── SKILL.md                  # Core framework (≤300 lines, installed to ~/.{agent}/skills/autosdd/)
├── skills/                       # Bundled skills (installed to ~/.{agent}/skills/)
│   ├── autosdd-telemetry/SKILL.md  # /audit, /improve, /self-analysis
│   ├── feedback-report/SKILL.md  # /feedback [timerange]
│   └── knowledge-graph/SKILL.md  # /knowledge-graph — memory visualization
├── shared/                       # Shared protocols (installed to ~/.{agent}/skills/_shared/)
│   ├── rtk.md                    # RTK token optimization (autoSDD owns this)
│   ├── persona.md                # Agent persona, rules (gentle-ai origin)
│   ├── sdd-orchestrator.md       # SDD delegation protocol (gentle-ai origin)
│   ├── engram-protocol.md        # Engram memory protocol (gentle-ai origin)
│   └── model-assignments.md      # Phase → model mapping (gentle-ai origin)
├── templates/                    # Project templates (copied to project on install)
│   ├── CLAUDE.md                 # Slim index — SOURCE OF TRUTH for installed CLAUDE.md
│   ├── autosdd.md                # Framework reference card
│   ├── guidelines.md             # Technical rules template
│   ├── user_context.md           # User profile template
│   ├── business_logic.md         # Domain knowledge template
│   └── knowledge-graph.html      # Standalone graph viewer
├── scripts/
│   ├── auto-resume.sh            # Rate-limit recovery wrapper (macOS/Linux)
│   └── auto-resume.ps1           # Rate-limit recovery wrapper (Windows)
├── patches/
│   └── engram-embedding.patch    # Patch for Engram MCP embedding layer
├── docs/
│   ├── testing-strategy.md       # TDD testing guide
│   ├── skill-lifecycle.md        # Skill activation protocol
│   ├── hooks.md                  # Claude Code hooks reference
│   ├── mcp-setup.md              # MCP configuration guide
│   └── iron-man-roadmap.md       # Voice/mobile vision
└── .claude/
    ├── settings.json             # Hook definitions (deployed to projects by installer)
    └── hooks/                    # Hook scripts
```

---

## Updating

```bash
# Re-run installer (safe, idempotent)
curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash

# Or update skill only
curl -o ~/.claude/skills/autosdd/SKILL.md \
  https://raw.githubusercontent.com/thestark77/autosdd/main/skill/SKILL.md

# Or update gentle-ai only
gentle-ai upgrade && gentle-ai sync
```

---

## Relationship with gentle-ai

| Responsibility | gentle-ai | autoSDD |
|----------------|-----------|---------|
| Skill installation | Yes | No (uses gentle-ai) |
| Agent configuration | Yes | No (uses gentle-ai) |
| SDD phase skills (10) | Yes | References them |
| Engram memory | Yes | Uses it |
| `branch-pr` workflow | Yes | No (gentle-ai provides it) |
| `judgment-day` review | Yes | No (gentle-ai provides it) |
| **4-flow routing** | No | **Yes** |
| **CREA prompt engineering** | No | **Yes** |
| **Telemetry (/audit, /improve)** | No | **Yes** |
| **Bidirectional Feedback** | No | **Yes** |
| **Active feedback collection** | No | **Yes** |
| **TODO list management** | No | **Yes** |
| **3 Critical Context Files** | No | **Yes** |

gentle-ai = infrastructure. autoSDD = methodology + continuous improvement.

---

## Non-Negotiable Principles

1. **No code without a test** — TDD: RED → GREEN → REFACTOR
2. **No skipped quality gates** — pipeline gates G1-G4 verified before each phase transition
3. **No context loss** — every decision saved to Engram immediately, session observations at every step
4. **No polling** — Monitor tool for all waiting, event-driven always
5. **No silent failures** — escalate after 3 retries, never loop infinitely
6. **Specs are truth** — implementation matches specs, not the other way around
7. **Skills are the orchestrator's responsibility** — use them proactively, inject as TEXT
8. **Telemetry is mandatory** — every session can be audited, every version gets telemetry metrics
9. **The orchestrator DELEGATES** — never writes source code inline
10. **User messages get immediate attention** — mid-pipeline interrupts: answer first, re-prioritize, resume
11. **Core behaviors enforced structurally** — hooks, gates, and scripts, not just text suggestions
12. **English framework** — all skills, prompts, Engram content in English

---

## Created By

[**Gentleman Programming**](https://github.com/Gentleman-Programming) — Senior SaaS Architect, Google Developer Expert & Microsoft MVP.

## License

MIT
