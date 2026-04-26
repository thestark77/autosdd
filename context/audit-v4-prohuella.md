# autoSDD v4 Audit Report — ProHuella Session Analysis

**Session**: 0ca9347b-877d-43e6-88ac-53c03c016daf
**Project**: ProHuella
**Versions analyzed**: v2.6.3 (Schema+Seeds), v2.6.4 (API Layer)
**Date**: 2026-04-26
**Auditor**: External analysis from autoSDD repo session

---

## Executive Summary

The orchestrator produced functional output (23 Prisma models, seeds, 40 API route files) but **bypassed 95% of the autoSDD v4 framework**. It operated as a senior developer writing code directly, not as an orchestrator coordinating sub-agents through structured processes.

**Compliance score: ~8/100**

---

## 1. Evidence-Based Findings

### 1.1 Pipeline Execution: 0/7 steps followed

| Step | Required | Actually Done |
|------|----------|--------------|
| Prompt Analyst | Quality score 0-100, check 7 criteria | NOT DONE |
| Feedback Detector | Classify + persist user corrections | NOT DONE |
| Flow Router | Detect intent, select flow, log confidence | NOT DONE (jumped to explore) |
| CREA Refine | Structure with C/R/E/A + prompt-eng-patterns | NOT DONE |
| Execute Flow | Delegate to phase sub-agents | PARTIAL (8 agents, 5 failed, rest inline) |
| Outcome Collection | Metrics per phase | NOT DONE |
| Knowledge Update | Update context files + Engram | MINIMAL (1 reactive mem_save) |

### 1.2 Sub-Agent Delegations: 8 total, 0 compliant

| Metric | Count |
|--------|-------|
| Total Agent tool calls | 8 |
| With `## Project Standards (auto-resolved)` | 0 |
| With CREA structure | 0 |
| With `model` parameter | 0 |
| With `## Skills to Use` | 0 |
| With `subagent_type` specified | 1 (Explore) |
| That completed successfully | 2-3 of 7 apply agents |

**Example sub-agent prompt** (Health module, line 505):
```
Create API route files for the Health module in Pro Huella.
You must create 4 files. Follow the EXACT pattern shown below.
```
No role, no context section, no skill injection, no tool/MCP guidance.

### 1.3 Inline Work: Massive orchestrator overload

| Category | Inline operations | Should have been delegated? |
|----------|-------------------|----------------------------|
| Read calls | 44 | Yes (24+ were for exploration/understanding) |
| Write calls | 34 (29 API route files) | Yes (multi-file creation with logic) |
| Edit calls | 49 (14 schema + 35 TypeScript fixes) | Yes (all multi-file analysis+edit) |
| Bash calls | 40 (prisma, tsc, eslint, git) | Partially (test/build should delegate) |
| Grep calls | 7 | OK inline |
| **Total** | **183** | **~140 should have been delegated** |

The orchestrator wrote 29 API route files directly after sub-agents failed/timed out, instead of re-delegating with improved prompts.

### 1.4 prompt.md Quality: Technically good, framework-absent

All 5 prompt.md files (v2.6.3-v2.6.7) share these characteristics:

**What they did well:**
- Clear objectives with bounded scope
- Explicit file paths and pattern references
- Validation sections with specific commands
- Commit message templates
- Predecessor/dependency chain

**What was consistently missing (0/5 versions):**
- CREA section labels (Context/Role/Specificity/Action)
- Skills declared per task
- MCP references per task
- PromptInsights quality score
- Parallel vs blocking task annotations
- Engram memory as input (prior context)
- Only v2.6.7 mentions Engram at all (1 closing line)

### 1.5 Engram Usage: 2 calls total, both reactive

| Call | When | Proactive? |
|------|------|-----------|
| `mem_save` | Before compaction (line 405) | No (reactive to compaction) |
| `mem_context` | After compaction (line 454) | No (reactive to context loss) |

**Not done**: mem_search at session start, mem_save_prompt, proactive saves after decisions, mem_session_summary at end.

### 1.6 Skills: Zero activation

- No symlinks created in `.claude/skills/`
- No SKILL.md files read
- `prompt-engineering-patterns` never invoked despite explicit user request
- Only `Skill("compress")` was called (incorrectly — `/compact` is built-in)

### 1.7 feedback.md: Never generated

v2.6.3 and v2.6.4 both completed but no feedback.md was generated for either. The Version Close Protocol was not executed.

### 1.8 User Communication Failure

The user asked a direct question mid-session about skill usage. The orchestrator:
1. Ignored it the first time
2. User repeated: "contéstame primero lo que te pregunté y luego sigues lo que estás haciendo"
3. Orchestrator said "Let me push and then respondo tu pregunta" — continued prioritizing its own workflow
4. Eventually answered honestly after pushing

---

## 2. Root Cause Analysis

### 2.1 The SKILL.md is too long and relies on memory

At 546+ lines, the autoSDD SKILL.md contains:
- 10+ major sections with dozens of sub-requirements
- Multiple cross-references (skill-resolver.md, sdd-orchestrator.md, engram-protocol.md, model-assignments.md)
- Checklists that require the AI to remember 20+ mandatory steps

**Problem**: LLMs don't "memorize" instructions — they attend to them based on salience. When the orchestrator starts solving a real problem (schema design, API patterns), the high-salience technical work crowds out the low-salience procedural framework.

### 2.2 No enforcement mechanism

The framework is entirely trust-based. There is no:
- Pre-delegation checklist that blocks the Agent tool call
- Post-delegation validator that checks skill injection
- Gate between phases that verifies compliance
- Hook that detects when the orchestrator writes code inline

### 2.3 CREA is described but not templated

The framework says "use CREA" but doesn't provide a fill-in-the-blank template. The orchestrator has to remember the structure AND create it from scratch each time.

### 2.4 Triple CREA application is unrealistic

The framework currently demands CREA at three points:
1. User prompt analysis
2. prompt.md creation
3. Each sub-agent prompt

Applying the full CREA framework 10+ times per session (once per sub-agent) is:
- Token expensive (~500-1000 tokens per CREA block)
- Repetitive (context and role are often identical across tasks)
- Fragile (each application is another point where the AI can skip it)

### 2.5 Skill resolution is too many steps

Current protocol: search Engram for registry → get observation → cache → match by code context AND task context → copy compact rules → inject into prompt → check feedback loop

This is 6+ steps the orchestrator must remember to do BEFORE each delegation. In practice, it remembers zero of them.

### 2.6 The orchestrator defaults to "just do it"

When sub-agents failed (5 of 7 apply agents), the orchestrator chose to write 29 files inline instead of:
1. Diagnosing why the sub-agents failed
2. Improving the prompts
3. Re-delegating

This is the most damaging behavior: it inflated the context window by ~100k tokens and bypassed all quality gates.

---

## 3. Improvement Plan

### 3.1 Structural Changes to SKILL.md

#### A. Replace memory-based compliance with template-based compliance

**Current**: "Apply CREA to each sub-agent prompt" (the AI must remember HOW)
**Proposed**: Provide a literal template the AI fills in:

```markdown
## SUB-AGENT LAUNCH TEMPLATE (copy-paste, fill blanks)

### Context
- Project: {project_name}
- Current state: {what exists, what changed}
- Prior decisions: {relevant Engram memories}
- Constraints from guidelines.md: {extracted rules}

### Role
You are a {role} with expertise in {domain}.

### Standards (auto-resolved)
{paste compact rules from matched skills}

### Task
{exact deliverable — files, tests, output format}

### Tools Available
- MCPs: {list applicable MCPs}
- Skills: {list applicable skills with usage instructions}
- Validation: {commands to run before returning}

### Return Contract
Report: status, files_changed, tests_added, skill_resolution, discoveries_to_save
```

The orchestrator fills in blanks instead of constructing from memory.

#### B. Reduce CREA to ONE meaningful application point

**Current flow**: CREA on user prompt → CREA on prompt.md → CREA on each sub-agent
**Proposed flow**:

1. **User prompt → Light analysis only** (15 seconds, inline)
   - Is the prompt clear enough? (yes/no)
   - What flow? (dev/debug/review/research)
   - Quick score (high/medium/low)
   - If low → ask 1-3 questions. If medium/high → proceed.
   - NO full CREA here. This is triage, not refinement.

2. **prompt.md → FULL CREA structure** (the ONE place it matters)
   - This is the master plan. It gets the full treatment.
   - Includes skill routing per task, parallelism graph, Engram priming.
   - Uses prompt-engineering-patterns to select the right technique per task type.

3. **Sub-agent prompts → DERIVED from prompt.md** (mechanical extraction)
   - The orchestrator doesn't re-apply CREA — it extracts the relevant task from prompt.md
   - Adds compact rules from skill registry (cached)
   - Adds the launch template (fill in blanks)
   - This is assembly, not creative work.

This reduces CREA from 10+ applications to 1, makes it higher quality, and makes the sub-agent step mechanical.

#### C. Simplify skill resolution to 2 steps

**Current**: 6-step protocol across multiple files
**Proposed**: Single lookup table hardcoded in SKILL.md

```
FILE TOUCHES .prisma → inject: postgresql-table-design rules
FILE TOUCHES route.ts, /api/ → inject: error-handling-patterns rules
FILE TOUCHES .tsx (public pages) → inject: frontend-design rules
FILE TOUCHES .tsx (admin/dashboard) → inject: interface-design rules
FILE TOUCHES .test., .spec. → inject: testing-patterns rules
TASK IS PR → inject: branch-pr rules
TASK IS REVIEW → inject: judgment-day rules
```

No Engram search, no registry, no multi-step resolution. Pattern match → inject. Done.

The compact rules themselves should be embedded directly in the SKILL.md (or a single `skill-rules.md` file), not scattered across individual SKILL.md files that require reading.

### 3.2 Add Enforcement Mechanisms

#### A. Pre-Delegation Gate (add to CLAUDE.md as a hook concept)

Before ANY Agent tool call, the orchestrator MUST verify:
```
[ ] Prompt has Context section
[ ] Prompt has Role declaration
[ ] Prompt has ## Standards (auto-resolved) with at least 1 skill block
[ ] Prompt has explicit task deliverable
[ ] model parameter is set
```

This should be a mental checklist the SKILL.md drills into the orchestrator, placed IMMEDIATELY before the Agent tool call pattern (proximity = salience).

#### B. Anti-Inline Rule (make it visceral)

Current SKILL.md: orchestrator protocol buried in a separate file (sdd-orchestrator.md)
Proposed: Put it directly in SKILL.md Section 6 with HIGH salience:

```
STOP. Before writing ANY file:
- Am I the orchestrator or a sub-agent?
- If orchestrator: I do NOT write code. I delegate.
- The ONLY files I write: prompt.md, feedback.md, PROGRESS.md, context files.
- If I'm about to Write/Edit a .ts/.tsx/.prisma file → DELEGATE TO SUB-AGENT.

EXCEPTION: Single-line mechanical edits (version bump, import fix) = OK inline.
```

#### C. Compaction Safety Net

Add to the post-compaction hook: after recovering context, re-read the SKILL.md's "Core Behavior" section (or a 20-line summary) to re-prime the framework.

### 3.3 Reduce SKILL.md Size

**Current**: 546+ lines across SKILL.md + 4 shared protocol files
**Target**: < 200 lines in SKILL.md, with details pushed to on-demand references

Structure:
```
Lines 1-30:   Core pipeline (7 steps, 1 line each, with the template)
Lines 31-60:  CREA template (the fill-in-the-blank sub-agent launch template)
Lines 61-90:  Skill routing table (file pattern → rules to inject)
Lines 91-120: Anti-inline rules + delegation protocol
Lines 121-150: Engram protocol (save triggers + session close)
Lines 151-180: Version close protocol (feedback.md generation)
Lines 181-200: Self-improvement triggers
```

Everything else (A/B testing protocol, research flow details, self-improvement engine) moves to `autoSDD-reference.md` — read on demand, not loaded by default.

### 3.4 Fix Sub-Agent Failure Recovery

Add explicit recovery protocol:
```
When a sub-agent fails or returns incomplete results:
1. DIAGNOSE: What went wrong? (timeout, missing context, wrong model?)
2. IMPROVE PROMPT: Add the missing context, clarify the ambiguity
3. RE-DELEGATE: Launch a new sub-agent with the improved prompt
4. NEVER write the code yourself. You are the orchestrator.
5. After 2 failed re-delegations → escalate to user with diagnosis
```

### 3.5 Skills Ecosystem Changes

#### Remove from auto-install:
- `knowledge-graph` — nice to have, not core to development flow
- `feedback-report` — can be generated inline by the orchestrator
- `claude-md-improver` — rarely needed, can be manual

#### Keep and strengthen:
- `prompt-engineering-patterns` — but embed its TOP 3 techniques directly in the CREA template
- `error-handling-patterns` — critical for API work
- `frontend-design` / `interface-design` — critical for UI work
- `judgment-day` — critical for quality gates
- `e2e-testing-patterns` — critical for verification

#### Add:
- `skill-rules-compact.md` — single file with ALL compact rules pre-extracted, ready for injection

### 3.6 CLAUDE.md Template Changes

The CLAUDE.md autoSDD block (currently 60+ lines) should be reduced to:
```
## autoSDD v4 (ALWAYS ACTIVE)
Pipeline: Analyze → Route → Plan (CREA) → Delegate → Collect → Update
Read: ~/.claude/skills/autosdd/SKILL.md
Key rule: Orchestrator DELEGATES. Never writes .ts/.tsx/.prisma files inline.
```

All details live in SKILL.md. The CLAUDE.md is a pointer, not a duplicate.

### 3.7 prompt.md Template

Create a `templates/prompt-template.md` that gets copied during install:

```markdown
# v{VERSION} — {TITLE}

> For: Autonomous agent orchestrator (SDD)
> Flow: {DEV/DEBUG/REVIEW/RESEARCH}
> Predecessor: v{PREV}
> Prompt Score: {HIGH/MEDIUM/LOW}

## Context
- Current state: {what exists}
- Problem: {what we're solving}
- Constraints: {from guidelines.md}
- Prior decisions: {from Engram}

## Tasks

### Task 1: {name}
- **Parallel**: {yes/no, depends on Task N}
- **Skills**: {list from routing table}
- **MCPs**: {Prisma, Playwright, etc.}
- **Files**: {paths to create/modify}
- **Validation**: {commands to run}
- **Model**: {sonnet/opus per model-assignments}

### Task 2: {name}
...

## Commits
{segmented by module group}

## Version Close
- [ ] All tasks complete
- [ ] tsc clean
- [ ] lint clean
- [ ] tests pass
- [ ] feedback.md generated
- [ ] Engram session summary saved
```

---

## 4. Priority Order

| Priority | Change | Impact | Effort |
|----------|--------|--------|--------|
| P0 | Sub-agent launch template (fill-in-the-blank) | Fixes skill injection, CREA compliance | Medium |
| P0 | Anti-inline rule (visceral, high salience) | Fixes context window bloat | Low |
| P0 | Reduce SKILL.md to < 200 lines | Fixes compliance drop-off | High |
| P1 | Single CREA application point (prompt.md only) | Reduces redundancy, increases quality | Medium |
| P1 | Simplified skill routing (pattern → inject) | Fixes skill resolution failure | Medium |
| P1 | prompt.md template with task structure | Fixes missing parallelism + skill routing | Low |
| P1 | Sub-agent failure recovery protocol | Fixes inline takeover | Low |
| P2 | Compact rules single file | Reduces token cost of skill injection | Medium |
| P2 | CLAUDE.md reduction (pointer, not duplicate) | Reduces noise in context | Low |
| P2 | Ecosystem trim (remove 3, add 1) | Reduces cognitive load | Low |

---

## 5. Metrics for Success

After implementing these changes, measure on the next 3 sessions:

| Metric | Current (ProHuella) | Target |
|--------|-------------------|--------|
| Pipeline steps followed | 0/7 | >= 5/7 |
| Sub-agents with skill injection | 0/8 | >= 80% |
| Sub-agents with CREA | 0/8 | >= 80% |
| Sub-agents with model param | 0/8 | 100% |
| Inline Write/Edit of .ts files | 63 | < 5 |
| feedback.md generated per version | 0/2 | 100% |
| Engram proactive saves | 1 | >= 5 per session |
| PromptInsights generated | 0 | 1 per version |
| Compaction-causing context bloat | Yes | No |
