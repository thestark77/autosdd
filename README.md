# AutoSDD v3 — Self-Improving Autonomous Development

<div align="center">

**Talk to your AI. It asks questions. Then it builds everything autonomously — and gets better at it over time.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-blue)](https://claude.ai/claude-code)
[![gentle-ai](https://img.shields.io/badge/gentle--ai-FUNDAMENTAL-red)](https://github.com/Gentleman-Programming/gentle-ai)
[![RTK](https://img.shields.io/badge/RTK-Token%20Killer-orange)](https://github.com/rtk-ai/rtk)
[![Made by Gentleman Programming](https://img.shields.io/badge/Made%20by-Gentleman%20Programming-blueviolet)](https://github.com/Gentleman-Programming)

</div>

---

## What Is autoSDD?

autoSDD is a **methodology layer** on top of [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai). It adds:

- **5 Flows** — auto-detect if you're developing, debugging, reviewing, researching, or improving
- **CREA Framework** — structured prompt engineering on EVERY prompt (Context, Role, Specificity, Action)
- **Self-Improvement** — the framework measures its own performance and A/B tests its own process
- **TODO Lists** — persistent orchestrator + user task tracking that survives compaction
- **3 Sacred Context Files** — living docs the AI auto-updates: guidelines, user profile, business logic
- **Event-Driven** — Monitor tool for all waiting, NEVER polling or sleep loops

gentle-ai provides the **infrastructure** (skills, MCPs, agents, TUI). autoSDD provides the **process**.

---

## Flow Diagram

```
USER PROMPT (voice/text)
    |
    v
+-------------------+
|   FLOW ROUTER     |  Detect intent: dev? debug? review? research? improve?
+-------------------+
    |
    v
+-------------------+
|   CREA REFINE     |  Context + Role + Specificity + Action
+-------------------+
    |
    v
+------+------+------+------+------+
| DEV  |DEBUG |REVIEW|RSCH  |SELF  |
|      |      |      |      |IMPRV |
+------+------+------+------+------+
    |
    v
+-------------------+
| OUTCOME COLLECT   |  Tokens, duration, pass/fail, retries
+-------------------+
    |
    v
+-------------------+
| KNOWLEDGE UPDATE  |  Context files, Engram, wiki
+-------------------+
```

### Development Flow (most common)

```
PROMPT REFINE -> INTAKE -> PLAN -> BUILD (TDD) -> VERIFY -> CERTIFY -> SHIP -> REVIEW
```

### Debug Flow

```
REPRODUCE -> DIAGNOSE -> FIX (TDD) -> VERIFY -> DOCUMENT
```

### Code Review Flow

```
INGEST -> ANALYZE (6 agents + judgment-day) -> REPORT -> [FIX optional]
```

---

## Requirements

### Mandatory

| Tool | Purpose | Install |
|------|---------|---------|
| [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) | **CORE** — SDD skills, Engram memory, agent config | See [gentle-ai install guide](https://github.com/Gentleman-Programming/gentle-ai#installation) |
| [RTK](https://github.com/rtk-ai/rtk) | Token-optimized CLI output (60-90% savings) | Auto-installed by installer |
| prompt-engineering-patterns | **CORE** — CREA prompt techniques (Chain-of-Thought, Few-Shot, etc.) | Installed by gentle-ai `--preset full-gentleman` |
| AI Agent | Claude Code, Cursor, Codex, Windsurf, Kiro, Gemini CLI | Agent-specific |

### Recommended Plugins (Claude Code)

| Plugin | Purpose |
|--------|---------|
| Context7 | Live library docs — prevents hallucinated APIs |
| Ralph Loop | Autonomous iteration (run until tests pass) |
| PR Review Toolkit | 6 specialized code review agents |
| TypeScript LSP | Go-to-definition for TS projects |
| Skill Creator | A/B test and benchmark skills |
| CLAUDE.md Management | Auto-audit CLAUDE.md quality |

### Recommended MCPs

| MCP | Purpose |
|-----|---------|
| [Engram](https://github.com/nicobailon/engram) | Persistent memory (installed via gentle-ai) |
| Prisma | Database operations |
| Railway / Vercel | Deployment monitoring |
| Sentry | Production error tracking |

---

## Installation (One Command)

### Prerequisites

The installer needs a package manager to install [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) automatically. If you already have gentle-ai installed, you can skip this.

| OS | Package Manager | Install |
|----|----------------|---------|
| macOS / Linux | [Homebrew](https://brew.sh) | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| Windows | [Scoop](https://scoop.sh) | `irm get.scoop.sh \| iex` |

The installer will automatically add the correct tap/bucket and install gentle-ai for you.

### Quick Install (recommended)

> **IMPORTANT**: Run the install command **from inside your project directory** (the folder where your code lives). The installer bootstraps templates and injects the autoSDD block into your project's CLAUDE.md. If you run it from the wrong directory, files will land in the wrong place.

The install script installs gentle-ai + autoSDD with the recommended configuration. It asks only 2 questions:
1. **Which AI agents?** (default: all)
2. **Response style?** (default: neutral)

Everything else is pre-configured: multi-agent SDD, optimal model assignments, all components.

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/thestark77/autosdd/main/install.ps1 | iex
```

> **Prerequisite**: [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) must be installed first. The script will tell you how if it's missing.

### Manual Install

If you prefer manual control:

```bash
# 1. Install gentle-ai
gentle-ai install --preset full-gentleman --sdd-mode multi

# 2. Install autoSDD skill (Claude Code)
mkdir -p ~/.claude/skills/autosdd
curl -o ~/.claude/skills/autosdd/SKILL.md \
  https://raw.githubusercontent.com/thestark77/autosdd/main/skill/SKILL.md

# 3. For other agents, replace ~/.claude/ with:
#    Cursor:    ~/.cursor/
#    Codex:     ~/.codex/
#    Windsurf:  ~/.codeium/windsurf/
#    Kiro:      ~/.kiro/
#    Gemini:    ~/.gemini/
```

The installer does **everything** in one command:

1. Installs **gentle-ai** with your agent + persona preferences
2. Installs **autoSDD skill** to each selected agent
3. Installs **RTK** (token optimization — 60-90% savings on CLI output)
4. Verifies **prompt-engineering-patterns** is available (CORE skill, used with CREA)
5. Bootstraps **project templates** (`context/` + `CLAUDE.md`) in the current directory
6. **Injects autoSDD block** into existing CLAUDE.md (or creates from template if none exists)

The CLAUDE.md injection uses HTML markers (`<!-- autosdd:start -->` / `<!-- autosdd:end -->`). This means:
- **No CLAUDE.md** → copies the full template
- **Existing CLAUDE.md, first install** → appends the autoSDD activation block
- **Existing CLAUDE.md, update** → replaces ONLY the block between markers (your content untouched)

Running the installer multiple times is always safe (idempotent).

> **Note**: Run the installer FROM your project directory so templates land in the right place.

### After Installation

Open your project in your AI agent and run:

```bash
/sdd-init          # Detects stack, creates context files, configures SDD
/sdd-new feature   # Start building
```

### Verify Installation

```bash
/sdd-init          # Should detect your stack and configure
/sdd-explore test  # Should explore your codebase
```

---

## Use Cases

### "Build a new feature"
```
You: "Add user registration with email verification"
autoSDD: DEV flow -> CREA refine -> explore -> propose -> spec -> design -> tasks -> apply (TDD) -> verify -> ship
```

### "Fix a bug"
```
You: "Login fails with 500 error on mobile"
autoSDD: DEBUG flow -> reproduce -> diagnose (search Engram for prior occurrences) -> fix (TDD) -> verify -> document
```

### "Review this PR"
```
You: "Review PR #45"
autoSDD: REVIEW flow -> analyze (6 agents + judgment-day in parallel) -> report (CRITICAL/WARNING/INFO) -> [fix if requested]
```

### "Should we use X?"
```
You: "Should we migrate from REST to tRPC?"
autoSDD: RESEARCH flow -> scope -> gather (web + docs + Engram) -> evaluate (scoring matrix) -> synthesize -> decide
```

### "Improve the framework"
```
You: "Optimize token usage in BUILD phase"
autoSDD: SELF-IMPROVE flow -> measure current metrics -> hypothesize -> A/B test -> evaluate -> apply/discard
```

### "I'm going to sleep"
```
You: "Me voy a dormir, terminá todo"
autoSDD: Asks critical questions IMMEDIATELY -> executes full plan autonomously -> commits -> pushes -> saves summary to Engram
```

---

## Key Concepts

### CREA Framework + prompt-engineering-patterns

Every prompt created by autoSDD uses **CREA structure** combined with **prompt-engineering-patterns** techniques:

| Component | What to Include |
|-----------|----------------|
| **Context** | Project state, what exists, what changed, relevant guidelines/business logic |
| **Role** | Professional expertise — architect for design, implementer for apply, reviewer for verify |
| **Specificity** | Constraints, skills, tools, gotchas, anti-patterns, testing instructions |
| **Action** | Exact deliverable — files to create/modify, tests to write, what to save |

prompt-engineering-patterns provides the techniques (Chain-of-Thought, Few-Shot, Structured Output, Self-Consistency) that CREA structures. They work together — CREA defines the WHAT, prompt-engineering-patterns defines the HOW. Both are applied on **every** prompt creation and refinement.

### Three Critical Context Files

| File | Purpose | Auto-Updated When... |
|------|---------|---------------------|
| `context/guidelines.md` | Technical rules, conventions | New gotcha, convention, pattern |
| `context/user_context.md` | User profile, preferences | User shares personal/professional info |
| `context/business_logic.md` | Domain knowledge, entities | Business rule, workflow detail |

### TODO Lists

| List | Purpose | Storage |
|------|---------|---------|
| **Agent TODO** | Orchestrator's action plan — survives compaction | Claude memory + Engram backup |
| **User TODO** | Things the user needs to do (outside AI scope) | Claude memory + Engram backup |

### Action Clarity Protocol

Before modifying files, autoSDD classifies user intent:
- **Execute**: "hacelo", "dale", "implement" -> write code
- **Respond**: "what do you think?", "analyze" -> analysis only
- **Plan**: "propose", "plan" -> create plan, no execution
- **Unclear**: ask immediately

### Monitor-First (Event-Driven)

| Wait For | Method |
|----------|--------|
| Deploy | Monitor tool -> Railway/Vercel logs |
| Tests | Monitor tool -> test output |
| Sub-agents | Background Agent (auto-notifies) |
| Timed wait | ScheduleWakeup (only when user requests) |

**NEVER**: sleep, polling, repeated status checks.

---

## Updating

### Update everything (re-run installer)
```bash
# macOS/Linux
curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash

# Windows
irm https://raw.githubusercontent.com/thestark77/autosdd/main/install.ps1 | iex
```

Re-running the installer is safe — it updates SKILL.md, refreshes the CLAUDE.md block between markers, and skips existing templates.

### Update autoSDD skill only
```bash
curl -o ~/.claude/skills/autosdd/SKILL.md \
  https://raw.githubusercontent.com/thestark77/autosdd/main/skill/SKILL.md
```

### Update gentle-ai only
```bash
gentle-ai upgrade
gentle-ai sync
```

Both update independently without conflicts. gentle-ai manages its sections with markers, autoSDD manages its own SKILL.md and CLAUDE.md block (`<!-- autosdd:start/end -->`).

---

## File Structure

```
autosdd/
├── README.md                    # This file
├── install.sh                   # One-command installer (macOS/Linux)
├── install.ps1                  # One-command installer (Windows)
├── skill/
│   └── SKILL.md                 # autoSDD v3.1 skill (installed to ~/.{agent}/skills/autosdd/)
├── templates/
│   ├── CLAUDE.md                # Template CLAUDE.md (includes autoSDD activation block)
│   ├── autosdd.md               # autoSDD v3 framework reference (→ context/autosdd.md)
│   ├── guidelines.md            # Template for technical rules and conventions
│   ├── user_context.md          # Template for user profile and preferences
│   └── business_logic.md        # Template for business domain knowledge
└── docs/
    ├── testing-strategy.md      # Full testing strategy
    ├── skill-lifecycle.md       # Skill activation/deactivation protocol
    ├── mcp-setup.md             # MCP server configuration guide
    ├── iron-man-roadmap.md      # Voice/mobile integration roadmap
    └── hooks.md                 # Claude Code hooks reference
```

---

## Relationship with gentle-ai

autoSDD is built ON TOP of [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai):

| Responsibility | gentle-ai | autoSDD |
|----------------|-----------|---------|
| Skill installation | Yes | No (uses gentle-ai) |
| Agent configuration (12 agents) | Yes | No (uses gentle-ai) |
| SDD phase skills (10 skills) | Yes | References them |
| Engram memory | Yes | Uses it |
| TUI for setup | Yes | No |
| Backup/rollback | Yes | No |
| **5-flow routing** | No | **Yes** |
| **CREA prompt engineering** | No | **Yes** |
| **Self-improvement engine** | No | **Yes** |
| **TODO lists** | No | **Yes** |
| **Action Clarity Protocol** | No | **Yes** |
| **Outcome metrics** | No | **Yes** |
| **3 Critical Context Files** | No | **Yes** |

gentle-ai is the **infrastructure**. autoSDD is the **methodology**.

---

## Non-Negotiable Principles

1. **No code without a test** — TDD: RED -> GREEN -> REFACTOR
2. **No mock databases** — integration tests hit real PostgreSQL
3. **No skipped quality gates** — every phase must pass before the next
4. **No context loss** — every decision saved to Engram immediately
5. **No polling** — Monitor tool for all waiting, event-driven always
6. **No silent failures** — escalate after 3 retries, never loop infinitely
7. **Specs are truth** — implementation matches specs, not the other way around
8. **English framework** — all skills, prompts, Engram content in English

---

## Related Projects

| Project | Role |
|---------|------|
| [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) | **CORE** — skill management, SDD orchestration, Engram memory |
| [RTK](https://github.com/rtk-ai/rtk) | Token optimization — 60-90% savings on CLI commands |
| [Engram](https://github.com/nicobailon/engram) | Persistent memory MCP (installed via gentle-ai) |

---

## Created By

[**Gentleman Programming**](https://github.com/Gentleman-Programming) — Senior SaaS Architect, Google Developer Expert & Microsoft MVP.

---

## License

MIT — see [LICENSE](LICENSE)
