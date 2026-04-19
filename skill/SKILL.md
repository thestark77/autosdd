---
name: autosdd
description: >
  Self-improving autonomous development framework. Routes prompts to 5 flows
  (Development, Code Review, Debugging, Research, Self-Improvement), applies
  CREA prompt engineering on ALL prompt creation, enforces SDD methodology,
  tracks metrics, and auto-improves through A/B testing. ALWAYS ACTIVE unless
  user explicitly opts out.
version: "3.1.0"
license: MIT
metadata:
  author: gentleman-programming
  repository: https://github.com/thestark77/autosdd
  requires:
    - gentle-ai (SDD skills + Engram memory)
    - prompt-engineering-patterns skill
    - RTK (Rust Token Killer)
  compatible_agents:
    - Claude Code
    - OpenAI Codex
    - Cursor
    - VS Code Copilot
    - Windsurf
    - Kiro
    - Gemini CLI
---

# autoSDD v3 — Self-Improving Autonomous Development Framework

> **This skill is ALWAYS ACTIVE.** Every prompt goes through autoSDD unless the user explicitly says otherwise (e.g., "skip autosdd", "raw mode", "no framework").

## Quick Start

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash

# Windows (PowerShell)
irm https://raw.githubusercontent.com/thestark77/autosdd/main/install.ps1 | iex
```

The installer configures gentle-ai, autoSDD skill, RTK, prompt-engineering-patterns, and project templates — all in one command.

---

## 1. Core Behavior — ALWAYS ON

When this skill is active, EVERY user prompt goes through the following pipeline:

```
USER PROMPT
    ↓
[1] FLOW ROUTER — detect intent, select flow
    ↓
[2] CREA PROMPT REFINE — structure with Context, Role, Specificity, Action
    ↓
[3] EXECUTE FLOW — one of 5 flows (Dev, Review, Debug, Research, Self-Improve)
    ↓
[4] OUTCOME COLLECTION — metrics, tokens, pass/fail
    ↓
[5] KNOWLEDGE UPDATE — update context files, Engram, wiki if relevant
```

### Opt-Out

The user can disable autoSDD for a specific prompt:
- `[raw]` prefix: skip framework entirely
- `[no-sdd]` prefix: skip SDD phases but keep CREA
- `skip autosdd`: natural language opt-out

---

## 2. CREA Framework — Mandatory Prompt Infrastructure

**EVERY prompt created or refined by autoSDD MUST use CREA structure.**

CREA (Contexto, Rol, Especificidad, Accion) eliminates ambiguity:

| Component | What to Include |
|-----------|----------------|
| **Context** | Project state, what exists, what changed, what problem we're solving. Include relevant sections from guidelines.md, user_context.md, business_logic.md |
| **Role** | Professional expertise the agent should adopt. Phase-specific: architect for design, implementer for apply, reviewer for verify |
| **Specificity** | Constraints, skills to use, tools available, learned gotchas, anti-patterns, testing instructions, Monitor tool patterns |
| **Action** | Exact deliverable: files to create/modify, tests to write, output format, what to save to Engram |

### CREA + prompt-engineering-patterns

CREA provides STRUCTURE. The `prompt-engineering-patterns` skill provides TECHNIQUES:

- Chain-of-Thought: when reasoning is needed
- Few-Shot Examples: when pattern matching is needed
- Structured Output: when specific format is needed
- Self-Consistency: when high-stakes decisions

Both are MANDATORY on every prompt creation — user-facing, sub-agent, or document updates.

### CREA Validation Gate

Before sending ANY prompt to a sub-agent:
1. Has explicit CONTEXT? (not assumed)
2. Has clear ROLE? (not generic)
3. Has SPECIFIC constraints? (not vague)
4. Has concrete ACTION? (not "figure it out")
→ Missing any → REFINE before sending.

---

## 3. Flow Router

Detect user intent BEFORE selecting a workflow:

| Signal | Flow | Confidence |
|--------|------|------------|
| Feature, add, create, implement, refactor | **DEV** | 90% |
| Fix, bug, error, stack trace, broken, failing | **DEBUG** | 90% |
| Review, PR, look at this code, check this | **REVIEW** | 90% |
| Research, evaluate, compare, should we use | **RESEARCH** | 85% |
| Improve autosdd, benchmark, optimize framework | **SELF-IMPROVE** | 95% |

**Override**: `[dev]`, `[debug]`, `[review]`, `[research]`, `[improve]` prefix.
**Ambiguous** (confidence < 80%): default to DEV flow.

---

## 4. Five Flows

### 4.1 Development Flow

```
PROMPT REFINE → INTAKE → PLAN → BUILD → VERIFY → CERTIFY → SHIP → REVIEW & NEXT
```

Key behaviors:
- PROMPT REFINE: Apply CREA + prompt-engineering-patterns. Query Context7 for live docs. Enrich per-task with skills, tools, gotchas from all 3 context files.
- BUILD: Use Ralph Loop for autonomous iteration (run until tests pass, max iterations).
- VERIFY: PR Review Toolkit (6 agents) as Layer 1 + judgment-day as Layer 2.
- SHIP: Monitor tool for deploy events (NEVER poll).
- REVIEW: Write changelog.md, metrics.md, learnings.md to version folder.
- ALL phases: Report tokens and duration to Outcome Collector.

Version folder per change:
```
context/appVersions/vX.Y.Z/
  original_prompt.md    # Raw user prompt
  prompt.md             # CREA-refined execution plan (updated during execution)
  feedback.md           # Sub-agent findings
  changelog.md          # What changed, why, impact
  metrics.md            # Outcome Record
  learnings.md          # What agent learned
  screenshots/{task}/   # Playwright CLI screenshots
  outputs/              # Reports, artifacts
```

### 4.2 Code Review Flow

```
INGEST → ANALYZE → REPORT → [FIX (optional)]
```

- ANALYZE: Launch PR Review Toolkit 6 agents + judgment-day in parallel
- REPORT: Categorize as CRITICAL / WARNING / INFO / SUGGESTION
- FIX: Only if user says "fix it" — apply CRITICAL + WARNING fixes only

### 4.3 Debugging Flow

```
REPRODUCE → DIAGNOSE → FIX → VERIFY → DOCUMENT
```

- REPRODUCE: Search Engram for prior occurrences first. If known → apply fix immediately.
- DIAGNOSE: TypeScript LSP for precise navigation. Git blame for recent changes.
- FIX: TDD — write failing test (RED), implement fix (GREEN), anti-regression check.
- DOCUMENT: Save to Engram, update guidelines.md gotchas if recurring.

### 4.4 Research Flow

```
SCOPE → GATHER → EVALUATE → SYNTHESIZE → DECIDE
```

- GATHER: WebSearch + WebFetch + Context7 + Engram prior research
- EVALUATE: Score candidates 1-5 per criterion, build comparison matrix
- SYNTHESIZE: Save to Engram as `research/{topic}` + `ai-context/research/`

### 4.5 Self-Improvement Flow

```
MEASURE → HYPOTHESIZE → EXPERIMENT → EVALUATE → APPLY/DISCARD → DISCOVER
```

Autoresearch-inspired: change parameter → run experiment → measure metric → keep/discard.

Triggered: explicitly OR auto every 5th DEV flow.

Optimizes: CLAUDE.md sections, skill injection, judge rubric, timeout budgets, sub-agent prompts.

---

## 5. Three Critical Context Files

autoSDD maintains 3 sacred living documents. The orchestrator MUST update them whenever relevant information is discovered.

| File | Purpose | Update Triggers |
|------|---------|----------------|
| `context/guidelines.md` | Technical rules, conventions, constraints | New gotcha, convention, post-mortem pattern |
| `context/user_context.md` | User profile, preferences, workflow | User provides personal/professional info |
| `context/business_logic.md` | Domain knowledge, entities, workflows | Business rule, entity relationship, workflow detail |

**Rule: if information belongs in one of these files, UPDATE IT IMMEDIATELY. Never defer.**

Sub-agents never read these directly. The orchestrator extracts relevant sections and injects them via CREA-structured prompts.

---

## 6. Orchestrator Prompt Enrichment

For EACH task delegated to a sub-agent, the orchestrator MUST:

1. Extract relevant sections from guidelines.md, user_context.md, business_logic.md
2. Match skills from skill registry to task files
3. Query Engram for gotchas and post-mortems
4. Query Context7 for library docs
5. Apply CREA structure + prompt-engineering-patterns
6. Include: skill assignments, tool/MCP assignments, learned warnings, testing instructions, Monitor patterns

---

## 7. Action Clarity Protocol

Before modifying ANY file, classify user intent:
- **EXECUTE**: "hacelo", "dale", "implement", "apply", "fix it" → write code
- **RESPOND**: "¿qué opinás?", "analyze", "what do you think?" → analysis only, NO file changes
- **PLAN**: "planificá", "proponé", "plan", "propose" → create plan, NO execution
- **UNCLEAR**: ASK → "¿Querés que lo ejecute o solo que te dé mi opinión?"

When Stop hook fires while waiting: stop cleanly, do NOT loop, do NOT start unrelated work.

---

## 7.1 Root Cause Feedback Protocol

When the user reports a **bug, error, or problem**, ALWAYS follow this sequence:

1. **Diagnose**: Identify the exact root cause (code-level, architectural, or environmental)
2. **Explain FIRST**: Before touching any file, give a concise summary:
   - **Causa**: One sentence — what exactly is wrong and WHY it happens (technical root cause)
   - **Solución**: One sentence — what the fix is at a technical level
3. **Then fix**: Proceed with the implementation

This teaches the user to recognize patterns and builds their technical intuition. The explanation should be SHORT (2-4 lines max), not a lecture. Focus on the WHY — the pattern they can recognize next time.

Example:
> **Causa**: `gentle-ai install` returns exit code 1 for non-critical verification warnings, and our script treats any non-zero exit as fatal. False positive.
> **Solución**: Treat exit code 1 as warning (log + continue), not as hard failure.

This applies to ALL flows (Dev, Debug, Review) whenever the trigger is a user-reported problem.

---

## 8. Event-Driven Monitoring (Monitor-First Policy)

**NEVER use `sleep` or polling.** ALWAYS use event-driven tools:

| Wait For | Method | NEVER |
|----------|--------|-------|
| Deploy | Monitor tool → Railway logs | Poll with curl |
| Tests | Monitor tool → test output | Sleep + re-run |
| Build | Monitor tool → tsc output | Sleep + check |
| Sub-agents | Background Agent (auto-notifies) | Sleep + poll |
| Timed wait (user-requested only) | ScheduleWakeup | Sleep command |
| User input | STOP cleanly | Loop asking |

ScheduleWakeup ONLY when user explicitly requests timed operations.

---

## 8. Knowledge System

Three layers:

```
Layer 1: Engram (raw observations, write-optimized, immediate)
Layer 2: Wiki (ai-context/wiki/, synthesized, read-optimized, syncs every 3rd flow)
Layer 3: Versions (context/appVersions/, per-change history)
```

Read path: Wiki first → Engram fallback → Version history for trends.

---

## 9. Self-Improvement Engine

### Metrics (Outcome Record per flow)

```yaml
flow, project, version, duration, tokens_per_phase, outcome_score,
retry_count, escalation_count, fix_iterations, judge_scores
```

### Outcome Scoring

| Outcome | Score |
|---------|-------|
| SUCCESS | 1.0 |
| PARTIAL | 0.7 |
| FIXED (2+ retries) | 0.5 |
| ESCALATED | 0.3 |
| FAILURE | 0.0 |

### A/B Testing Protocol

1. Define hypothesis + control + treatment
2. Run 3 executions with control, 3 with treatment
3. Compare: tokens, success rate, retries
4. Strictly better → APPLY. Mixed/worse → DISCARD.
5. ONE experiment at a time. Never change two variables simultaneously.

---

## 10. Auto-Installed Skills & Tools (Orchestrator Responsibility)

The autoSDD installer installs these skills GLOBALLY. The orchestrator MUST know them and use them AUTONOMOUSLY — without the user having to ask. It is the orchestrator's RESPONSIBILITY to decide which skills, MCPs, and tools to use for each task and to inject the relevant ones into sub-agent prompts.

### 10.1 Skill Routing Guide (MANDATORY)

The orchestrator MUST match skills to tasks. This table is the routing map:

| Task Context | Use These Skills | When |
|-------------|-----------------|------|
| Creating/refining ANY prompt | `prompt-engineering-patterns` + CREA | ALWAYS — hooks, sub-agents, LLMs, system prompts |
| Frontend UI (public-facing) | `frontend-design` | Landing pages, marketing, user-facing components |
| Admin/dashboard UI | `interface-design` | Dashboards, admin panels, internal tools |
| Pull requests | `branch-pr` | Creating, reviewing, or preparing PRs |
| Code review / debugging | `judgment-day` | Adversarial parallel review, critical bug diagnosis |
| E2E tests | `e2e-testing-patterns` + `playwright-cli` | Writing or fixing Playwright/Cypress tests |
| Error handling | `error-handling-patterns` | Implementing error handling, API error responses |
| CLAUDE.md updates | `claude-md-improver` | Auditing or updating CLAUDE.md files |
| Browser automation | `playwright-cli` | Screenshots, form testing, visual verification |

**Rule**: the orchestrator reads the relevant SKILL.md BEFORE delegating, extracts the compact rules, and injects them into the sub-agent prompt as `## Project Standards (auto-resolved)`. Sub-agents NEVER read SKILL.md files themselves.

**Rule**: EVERY prompt creation or refinement MUST use `prompt-engineering-patterns` + CREA framework. No exceptions. This applies to the orchestrator itself, not just sub-agents.

### 10.2 Auto-Installed Skills (via installer)

| Skill | Source | Purpose |
|-------|--------|---------|
| `autosdd` | [thestark77/autosdd](https://github.com/thestark77/autosdd) | This framework |
| `prompt-engineering-patterns` | [wshobson/agents](https://github.com/wshobson/agents) | CREA prompt techniques (CoT, Few-Shot, Structured Output) |
| `branch-pr` | [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) | PR creation workflow |
| `judgment-day` | [agent-teams-lite](https://github.com/Gentleman-Programming/agent-teams-lite) | Parallel adversarial code review |
| `frontend-design` | [anthropics/skills](https://github.com/anthropics/skills) | Production-grade frontend interfaces |
| `interface-design` | [dammyjay93/interface-design](https://github.com/dammyjay93/interface-design) | Dashboards, admin panels, internal tools |
| `claude-md-improver` | [claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | CLAUDE.md audit and improvement |
| `e2e-testing-patterns` | [wshobson/agents](https://github.com/wshobson/agents) | E2E testing with Playwright/Cypress |
| `error-handling-patterns` | [wshobson/agents](https://github.com/wshobson/agents) | Error handling across languages |
| `playwright-cli` | [microsoft/playwright-cli](https://github.com/microsoft/playwright-cli) | Browser automation and testing |

### 10.3 Auto-Installed via gentle-ai

| Component | Purpose |
|-----------|---------|
| SDD skills (10) | sdd-init, explore, propose, spec, design, tasks, apply, verify, archive, onboard |
| Engram MCP | Persistent cross-session memory |
| Context7 MCP | Live library/framework documentation |
| RTK | Token-optimized CLI output (60-90% savings) |

### 10.4 Core Dependency Gate (BLOCKING)

If ANY of these is missing, WARN and STOP:

| Core Dependency | Detection | Install |
|----------------|-----------|---------|
| **Engram MCP** | Check for `mem_save` tool | `gentle-ai install` |
| **Context7 MCP** | Check for `context7` tools | `gentle-ai install` |
| **prompt-engineering-patterns** | Check `~/.{agent}/skills/prompt-engineering-patterns/SKILL.md` | `npx skills add https://github.com/wshobson/agents --skill prompt-engineering-patterns` |
| **RTK** | Check `rtk` command | `cargo install rtk` |
| **Node.js** | Check `node` command | brew/scoop |

### 10.5 Recommended (NOT auto-installed, WARNING only)

| Tool | Purpose | Install |
|------|---------|---------|
| TypeScript LSP | Go-to-definition for TS projects | Plugin: `typescript-lsp` |
| code-review | Automated PR review | Plugin: `code-review` |
| code-simplifier | Post-implementation cleanup | Plugin: `code-simplifier` |
| claude-powerline | Status line | `npx -y @owloops/claude-powerline@latest` |

### 10.6 Inventory Protocol (SESSION START)

At session start, the orchestrator MUST:
1. **Detect available skills**: scan `~/.{agent}/skills/` and project skills
2. **Detect MCP servers**: engram, context7, prisma, railway, linear, sentry
3. **Detect CLI tools**: `rtk`, `node`, `go`, `gentle-ai`
4. **Cache capability map** for the session
5. **Save inventory to Engram**: `mem_save(topic_key: "autosdd/session-inventory/{session-id}")`

---

## 11. Installation & Requirements

### Prerequisites

| Requirement | Auto-installed? | Manual install |
|-------------|----------------|----------------|
| [Homebrew](https://brew.sh) / [Scoop](https://scoop.sh) | **NO** — install first | See links |
| [Node.js 18+](https://nodejs.org/) | **YES** via brew/scoop | https://nodejs.org/en/download |
| [Go](https://go.dev) | **YES** via brew/scoop | https://go.dev/dl/ |
| [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) | **YES** via brew/scoop | See gentle-ai docs |
| [RTK](https://github.com/rtk-ai/rtk) | **YES** via installer | `cargo install rtk` |
| Engram + Context7 MCPs | **YES** via gentle-ai | Included |
| SDD skills (10) | **YES** via gentle-ai | Included |
| 10 core skills (see §10.2) | **YES** via installer | See §10.2 sources |
| Project templates + CLAUDE.md | **YES** via installer | `context/` directory |

### Installation (One Command)

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/thestark77/autosdd/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/thestark77/autosdd/main/install.ps1 | iex
```

The installer:
1. Installs **Node.js + Go** (via brew/scoop if missing)
2. Installs **gentle-ai** (SDD skills, Engram, Context7)
3. Installs **10 core skills** globally per agent (from original sources)
4. Installs **RTK** (token optimization)
5. Bootstraps **project templates** (`context/` + `CLAUDE.md`)
6. Adds **GOBIN to PATH** (for engram binary)

### Post-Installation

```bash
/sdd-init          # Detects stack, creates context files, configures SDD
/sdd-new feature   # Start building
```

### Per-Project Bootstrap

After global installation, run `sdd-init` in each project to:
1. Detect stack (package.json, go.mod, etc.)
2. Install project-level skills in `.claude/skills/`
3. Create `context/guidelines.md`, `context/user_context.md`, `context/business_logic.md` if they don't exist
4. Create `ai-context/wiki/` directory
5. Save project context to Engram
6. Append autoSDD block to project CLAUDE.md (preserving existing content)

---

## 11. TODO Lists Protocol

Two persistent TODO lists, updated automatically at phase boundaries.

### Agent TODO (Orchestrator's Action Plan)

Storage: Claude native memory `todo_agent_{change}.md` + Engram backup `todo/agent/{project}/{change}`

```markdown
## Agent Plan — {change-name}
Status: IN_PROGRESS | 3/7 done

- [x] Task description → result
- [ ] Task description ⚠️ dependency note
  - [x] Subtask done
  - [ ] Subtask pending → BLOCKED: reason
- [ ] Task description
  NOTE: consideration
```

**Update**: plan creation, task completion, user interrupts, post-compaction, phase boundaries.
**Read**: session start, after compaction, before each phase, when user sends new prompt mid-task.

### User TODO (User's Pending Items)

Storage: Claude native memory `todo_user.md` + Engram backup `todo/user/{project}`

Tracks things outside AI scope or user-requested reminders. Auto-consulted at phase completion, session end, and when related to just-completed work.

---

## 12. Mid-Plan Interruption Handling

When a NEW user prompt arrives during active execution:

1. **PAUSE** current execution
2. **READ** agent TODO list
3. **CLASSIFY**: "do this NOW" → execute immediately. Clarification → update plan. New task → add + reprioritize. Affects completed work → create correction tasks.
4. **ANALYZE** impact on completed work: if downstream depends on broken work → correct FIRST. If cosmetic → correct AFTER.
5. **UPDATE** agent TODO with new priorities
6. **CONTINUE** with updated plan

---

## 13. User Profile Auto-Capture

When user shares ANY preference, constraint, or personal info:
1. Update `context/user_context.md` (project-specific)
2. Update Claude memory `user_profile.md` (cross-project)
3. Save to Engram `user-profile/{username}` as backup (cross-session)

Primary: Claude native memory (auto-loaded). Secondary: user_context.md. Backup: Engram.

---

## 14. Language Policy

- **Framework artifacts**: ALWAYS English (skills, prompts, Engram, wiki, changelogs, CLAUDE.md)
- **Project UI**: Project-specific (detected by sdd-init, usually Spanish neutral for LATAM SaaS)
- **Conversation**: Follow user's language (Spanish → Rioplatense, English → English)
- **Code**: ALWAYS English (variables, functions, types, comments, commits)

---

## 15. Compatibility

This skill follows the Agent Skills specification and works with any agent that reads SKILL.md files from a skills directory:

| Agent | Skills Directory | Status |
|-------|-----------------|--------|
| Claude Code | `~/.claude/skills/` | Full support |
| Cursor | `~/.cursor/skills/` | Full support |
| OpenAI Codex | `~/.codex/skills/` | Full support |
| Windsurf | `~/.windsurf/skills/` | Full support |
| Kiro | `~/.kiro/skills/` | Full support |
| VS Code Copilot | `~/.vscode/skills/` | Partial (depends on extension) |
| Gemini CLI | `~/.gemini/skills/` | Full support |

### Minimum Agent Requirements

For full autoSDD functionality, the agent needs:
- File read/write access
- Shell command execution
- Sub-agent delegation (for parallel BUILD batches)
- Memory/persistence (Engram or equivalent)
- Monitor tool or equivalent (for event-driven patterns)

Agents without sub-agent support will run flows sequentially instead of parallel.

---

*autoSDD v3.1.0 — April 2026*
*Author: Gentleman Programming (github.com/thestark77)*
*License: MIT*
