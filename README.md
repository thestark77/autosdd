# AutoSDD v4 — Self-Improving Autonomous Development

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

**v4 adds bidirectional feedback**: the AI educates the user to write better prompts, and the user teaches the AI their preferences and conventions. Every interaction makes both sides better.

### What autoSDD Adds

- **5 Flows** — auto-detect if you're developing, debugging, reviewing, researching, or improving
- **CREA Framework** — structured prompt engineering on every prompt (Context, Role, Specificity, Action)
- **Prompt Analyst** — proactive analysis of every user prompt for quality, skill gaps, and optimization opportunities
- **Bidirectional Feedback** — AI→User prompt coaching + User→AI preference learning, persisted across sessions
- **Self-Improvement Engine** — measures its own performance and A/B tests its own process
- **3 Sacred Context Files** — living docs the AI auto-updates: guidelines, user profile, business logic
- **Knowledge Graph** — Obsidian-like visualization of everything the AI knows about your project
- **Event-Driven** — Monitor tool for all waiting, never polling or sleep loops

---

## How It Works

Every user prompt flows through this pipeline:

1. **Prompt Analyst** — checks prompt quality (0-100), detects missing context, skill gaps, security concerns. Stops execution if score < 40.
2. **Feedback Detector** — checks if user is giving feedback ("no", "don't do that", "cambiá esto"). If yes, persists the correction to memory/files immediately.
3. **Flow Router** — detects intent: development, debugging, code review, research, or self-improvement.
4. **CREA Refine** — structures the prompt with Context, Role, Specificity, Action + prompt-engineering-patterns techniques.
5. **Execute Flow** — runs the selected flow (see below).
6. **Outcome Collection** — records tokens, duration, pass/fail, prompt quality score.
7. **Knowledge Update** — updates context files, Engram memory, wiki. Auto-generates feedback.md at version close.

### Development Flow

PROMPT REFINE → INTAKE → PLAN (explore → propose → spec → design → tasks) → BUILD (TDD: RED → GREEN → REFACTOR) → VERIFY → CERTIFY (judgment-day) → SHIP → REVIEW

### Debug Flow

REPRODUCE → DIAGNOSE → FIX (TDD) → VERIFY → DOCUMENT

### Code Review Flow

INGEST → ANALYZE (6 agents + judgment-day in parallel) → REPORT → FIX (optional)

### Research Flow

SCOPE → GATHER → EVALUATE (scoring matrix) → SYNTHESIZE → DECIDE

### Self-Improvement Flow

MEASURE → HYPOTHESIZE → EXPERIMENT → EVALUATE → APPLY/DISCARD

---

## Bidirectional Feedback (v4)

### AI → User

The AI proactively identifies weaknesses in your prompts and educates you:

- **Missing context**: "You didn't mention which auth pattern to follow"
- **Architecture gaps**: "This violates the repository pattern in your guidelines"
- **Security blind spots**: "No input validation mentioned for user data"
- **Skill gaps**: "You consistently skip database normalization — here's how to improve"
- **Token waste**: "3 debug cycles could have been avoided with clearer error reproduction steps"

At version close, a `feedback.md` report is auto-generated with all findings.

### User → AI

When you correct the AI, it persists the lesson:

- Technical corrections → `context/guidelines.md` + Engram
- Style preferences → `context/user_context.md` + Engram
- Agent errors → Engram (evaluated for SKILL.md updates if systemic)

The AI confirms: "Anotado. Guardé que [X]. No va a pasar de nuevo."

### Commands

| Command | What it does |
|---------|-------------|
| `/feedback` | Show feedback for last completed version |
| `/feedback week` | Aggregate feedback for last 7 days |
| `/feedback month` | Aggregate feedback for last 30 days |
| `/feedback v1.0..v2.0` | Feedback for a specific version range |
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
6. Bootstraps **project templates** (context/ + CLAUDE.md)

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
| `autosdd` skill | This framework — flow router, CREA, feedback engine, prompt analyst |
| `prompt-engineering-patterns` | CREA prompt techniques (CoT, Few-Shot, Structured Output) |
| `branch-pr` | PR creation workflow with issue-first enforcement |
| `judgment-day` | Parallel adversarial code review (two blind judges) |
| `frontend-design` | Production-grade frontend interfaces |
| `interface-design` | Dashboards, admin panels, internal tools |
| `claude-md-improver` | CLAUDE.md audit and improvement |
| `e2e-testing-patterns` | E2E testing with Playwright/Cypress |
| `error-handling-patterns` | Error handling across languages |
| `playwright-cli` | Browser automation and testing |
| `feedback-report` | Time-based feedback reports |
| `knowledge-graph` | Memory visualization as graph |
| `skill-creator` | Create new skills |
| `postgresql-table-design` | PostgreSQL schema best practices |
| Shared protocols (5) | persona, RTK, orchestrator, engram, model assignments |

### Auto-installed by gentle-ai

| Component | Purpose |
|-----------|---------|
| SDD skills (10) | sdd-init, explore, propose, spec, design, tasks, apply, verify, archive, onboard |
| Engram MCP | Persistent cross-session memory |
| Context7 MCP | Live library/framework documentation |
| RTK | Token-optimized CLI output |

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

**See AI's memory**: `/knowledge-graph` → interactive D3.js graph of all decisions, conventions, entities, and relationships

---

## File Structure

```
autosdd/
├── README.md
├── install.sh / install.ps1      # One-command installers
├── skill/
│   └── SKILL.md                  # autoSDD v4 framework (installed to ~/.{agent}/skills/autosdd/)
├── shared/                       # Extracted protocols (installed to ~/.{agent}/skills/_shared/)
│   ├── persona.md                # Agent persona, rules, language
│   ├── rtk.md                    # RTK token optimization instructions
│   ├── sdd-orchestrator.md       # SDD delegation, sub-agent protocol
│   ├── engram-protocol.md        # Engram memory protocol
│   └── model-assignments.md      # Phase → model mapping
├── skills/                       # Bundled skills (installed to ~/.{agent}/skills/)
│   ├── feedback-report/SKILL.md  # Time-based feedback reports
│   └── knowledge-graph/SKILL.md  # Memory visualization
├── templates/                    # Project templates (copied to project on install)
│   ├── CLAUDE.md                 # Slim index template
│   ├── autosdd.md                # Framework reference
│   ├── guidelines.md             # Technical rules template
│   ├── user_context.md           # User profile template
│   └── business_logic.md         # Domain knowledge template
└── docs/
    ├── testing-strategy.md       # TDD testing guide
    ├── skill-lifecycle.md        # Skill activation protocol
    ├── hooks.md                  # Claude Code hooks reference
    └── iron-man-roadmap.md       # Voice/mobile vision
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
| **5-flow routing** | No | **Yes** |
| **CREA prompt engineering** | No | **Yes** |
| **Prompt Analyst** | No | **Yes** |
| **Bidirectional Feedback** | No | **Yes** |
| **Self-improvement engine** | No | **Yes** |
| **Knowledge Graph** | No | **Yes** |
| **3 Critical Context Files** | No | **Yes** |

gentle-ai = infrastructure. autoSDD = methodology + continuous improvement.

---

## Non-Negotiable Principles

1. **No code without a test** — TDD: RED → GREEN → REFACTOR
2. **No skipped quality gates** — every phase must pass before the next
3. **No context loss** — every decision saved to Engram immediately
4. **No polling** — Monitor tool for all waiting, event-driven always
5. **No silent failures** — escalate after 3 retries, never loop infinitely
6. **Specs are truth** — implementation matches specs, not the other way around
7. **Skills are the orchestrator's responsibility** — use them proactively
8. **Feedback is mandatory** — every version gets a feedback report, every prompt gets analyzed
9. **English framework** — all skills, prompts, Engram content in English

---

## Created By

[**Gentleman Programming**](https://github.com/Gentleman-Programming) — Senior SaaS Architect, Google Developer Expert & Microsoft MVP.

## License

MIT
