---
name: autosdd
description: >
  Self-improving autonomous development framework. Routes prompts to 5 flows
  (Development, Code Review, Debugging, Research, Self-Improvement), applies
  CREA prompt engineering on ALL prompt creation, enforces SDD methodology,
  tracks metrics, and auto-improves through A/B testing. ALWAYS ACTIVE unless
  user explicitly opts out.
version: "3.0.0"
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
# One-command installation (any OS, any agent)
npx -y @anthropic-ai/claude-code skills add autosdd

# Or manual: copy this SKILL.md to your agent's skills directory
# Claude Code:  ~/.claude/skills/autosdd/SKILL.md
# Cursor:       ~/.cursor/skills/autosdd/SKILL.md
# Codex:        ~/.codex/skills/autosdd/SKILL.md
# Windsurf:     ~/.windsurf/skills/autosdd/SKILL.md
# Kiro:         ~/.kiro/skills/autosdd/SKILL.md
# VS Code:      ~/.vscode/skills/autosdd/SKILL.md
```

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

## 10. Installation & Requirements

### Prerequisites

| Requirement | Install Command | Purpose |
|-------------|----------------|---------|
| **Node.js 18+** | https://nodejs.org/ | Runtime |
| **Claude Code CLI** | `npm install -g @anthropic-ai/claude-code` | Primary agent (or any compatible agent) |
| **gentle-ai** | `npx -y gentle-ai@latest` | SDD skills + Engram memory |
| **RTK** | `cargo install rtk` or `npm install -g rtk-cli` | Token optimization (60-90% savings) |
| **Playwright CLI** | `npm install -g @playwright/cli@latest && playwright-cli install --skills` | Browser automation (4x cheaper than MCP) |
| **TypeScript LSP** | `npm install -g typescript-language-server typescript` | Go-to-definition for TS projects |

### Recommended Plugins (Claude Code)

```bash
# Install via Claude Code CLI
claude plugin install context7              # Live library documentation
claude plugin install ralph-loop            # Autonomous iteration engine
claude plugin install pr-review-toolkit     # 6 specialized review agents
claude plugin install typescript-lsp        # TypeScript navigation
claude plugin install claude-md-management  # CLAUDE.md quality audit
claude plugin install skill-creator         # Skill benchmarking & A/B testing
claude plugin install code-review           # Automated PR review
claude plugin install code-simplifier       # Post-implementation cleanup
```

### Recommended MCP Servers

| MCP | Purpose | Setup |
|-----|---------|-------|
| **Engram** | Persistent memory | Installed via gentle-ai |
| **Prisma** | Database operations | `pnpm dlx -y mcp-remote https://mcp.prisma.io/mcp` |
| **Railway** | Deployment | Configure in MCP settings |
| **Sentry** | Error monitoring | Configure in MCP settings |
| **Linear** | Issue tracking | Configure in MCP settings |

### SDD Skills (installed via gentle-ai)

```
sdd-init, sdd-explore, sdd-propose, sdd-spec, sdd-design,
sdd-tasks, sdd-apply, sdd-verify, sdd-archive, sdd-onboard
```

Plus: `judgment-day`, `skill-registry`, `skill-creator`, `prompt-engineering-patterns`

### Installation (One Command)

**Claude Code (any OS)**:
```bash
# Install gentle-ai (includes SDD skills + Engram)
npx -y gentle-ai@latest

# Copy autoSDD skill
mkdir -p ~/.claude/skills/autosdd
curl -o ~/.claude/skills/autosdd/SKILL.md https://raw.githubusercontent.com/thestark77/autosdd/main/skill/SKILL.md
```

**Cursor**:
```bash
npx -y gentle-ai@latest
mkdir -p ~/.cursor/skills/autosdd
curl -o ~/.cursor/skills/autosdd/SKILL.md https://raw.githubusercontent.com/thestark77/autosdd/main/skill/SKILL.md
```

**Codex**:
```bash
npx -y gentle-ai@latest
mkdir -p ~/.codex/skills/autosdd
curl -o ~/.codex/skills/autosdd/SKILL.md https://raw.githubusercontent.com/thestark77/autosdd/main/skill/SKILL.md
```

**Windsurf / Kiro / VS Code**:
```bash
npx -y gentle-ai@latest
# Replace {agent} with: .windsurf, .kiro, or .vscode
mkdir -p ~/{agent}/skills/autosdd
curl -o ~/{agent}/skills/autosdd/SKILL.md https://raw.githubusercontent.com/thestark77/autosdd/main/skill/SKILL.md
```

### Post-Installation: CLAUDE.md Integration

After installing autoSDD, the skill MUST be registered in the project's CLAUDE.md so it becomes the DEFAULT behavior. The installation script reads the existing CLAUDE.md, preserves ALL current content, and APPENDS the autoSDD activation block:

```markdown
## autoSDD — Active Framework (DO NOT REMOVE)

autoSDD v3 is the ACTIVE development framework for this project.
ALL prompts go through autoSDD unless the user explicitly opts out.

### Default Behavior
- Every prompt → Flow Router → CREA Prompt Refine → Execute Flow → Outcome Collection
- CREA framework (Context, Role, Specificity, Action) on ALL prompt creation
- prompt-engineering-patterns skill on ALL prompt refinement
- 5 flows: Development, Code Review, Debugging, Research, Self-Improvement
- Orchestrator delegates to sub-agents, NEVER executes directly
- Monitor tool for ALL waiting/watching (NEVER poll)
- RTK prefix on ALL shell commands

### Context Files (sacred, auto-updated)
- `context/guidelines.md` — Technical rules and conventions
- `context/user_context.md` — User profile and preferences
- `context/business_logic.md` — Domain knowledge and workflows

### Opt-Out
- `[raw]` prefix: skip framework entirely
- `[no-sdd]` prefix: skip SDD but keep CREA
- `skip autosdd`: natural language opt-out

Read the full framework specification: `context/autoSDDv3.md`
Read the autoSDD skill: `~/.claude/skills/autosdd/SKILL.md`
```

**CRITICAL**: The script NEVER replaces CLAUDE.md. It reads current content, preserves everything, and appends the autoSDD block at the end. If the block already exists, it updates it in place.

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
