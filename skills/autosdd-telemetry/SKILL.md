---
name: autosdd-telemetry
description: >
  Analyzes AI agent session logs to measure autoSDD framework compliance,
  detect orchestrator anti-patterns, and generate improvement recommendations.
  Manages session observations lifecycle and consolidated learning changelog.
  Triggered by /audit, /improve, and /self-analysis commands.
version: "2.1.0"
---

# autosdd-telemetry v2.1 — Session Analysis, Observations & Self-Improvement

## When to Use
- User says "dame las oportunidades de mejora", "/audit", "/improve"
- User provides session IDs or says "last", "last-3", "project:name"
- At version close, for generating telemetry section of feedback.md
- Framework self-improvement loop (observations → improve → learn)

---

## Session Observation Protocol (ALWAYS ACTIVE)

Session observations are the primary mechanism for framework self-improvement. They capture what ACTUALLY happened at each pipeline step, enabling cross-session analysis.

### When to Save Observations

The orchestrator MUST call `mem_save` after EACH pipeline step completes:

| Pipeline Step | Observation Includes |
|---------------|---------------------|
| TRIAGE | Prompt clarity score, mem_search results found, TODO items surfaced, reference asked? |
| ROUTE | Flow selected (DEV/DEBUG/REVIEW/RESEARCH), reasoning |
| PLAN (CREA) | prompt.md created? CREA sections present? Skills identified per task? |
| DELEGATE | Agent calls count, model params set?, Standards injected?, validation commands? |
| COLLECT | Results quality, re-delegations needed?, TODO items resolved? |
| CLOSE | feedback.md generated?, PROGRESS.md updated?, Engram summary saved? |
| KNOWLEDGE UPDATE | Context files updated?, discoveries saved? |

### Observation Format

```
mem_save({
  title: "Session observation: {STEP} - {project}",
  type: "telemetry",
  scope: "project",
  topic_key: "telemetry/obs/{project}/{session-marker}/{step}",
  content: `
    ## Step: {STEP}
    ## Session: {session-marker}
    ## Project: {project}
    ## Date: {YYYY-MM-DD}
    ## Status: pending

    ### What Happened
    {1-3 sentences: what the orchestrator did at this step}

    ### Compliance
    - SKILL.md adherence: {YES/PARTIAL/NO}
    - Deviations: {list specific deviations, or "none"}

    ### Metrics Snapshot
    {relevant counters at this point: tasks_delegated, tasks_inline, etc.}

    ### Observations
    {non-obvious findings, friction points, framework gaps, things that worked well}
  `
})
```

### Session Marker

At the START of each session, generate a unique session marker: `{YYYY-MM-DD-HHmm}`

Use this marker consistently in ALL observation topic_keys for the session. This allows `/improve` to search for all observations from a specific session.

Example topic_keys for a session:
- `telemetry/obs/prohuella/2026-04-26-1430/triage`
- `telemetry/obs/prohuella/2026-04-26-1430/route`
- `telemetry/obs/prohuella/2026-04-26-1430/delegate`
- `telemetry/obs/prohuella/2026-04-26-1430/close`

### Observation Lifecycle

Each observation has a `Status` field in its content:

| Status | Meaning |
|--------|---------|
| `pending` | Saved during session, not yet consumed by `/improve` |
| `applied` | Consumed by `/improve`, learnings extracted and applied to SKILL.md or LEARNING.md |

When `/improve` processes an observation, it calls `mem_update` to change `Status: pending` → `Status: applied` and appends `Applied: {date} - {improvement-id}`.

Observations are NEVER deleted — they form the audit trail of framework evolution.

---

## Consolidated Learning Protocol

Raw observations accumulate across sessions (7+ per session). To prevent context saturation, `/improve` CONSOLIDATES them into compact learnings stored by category.

### Learning Topic Key Taxonomy

```
learnings/{project}/{category}/{short-id}     # Project-specific
learnings/general/{category}/{short-id}        # Cross-project
```

**Categories** (semantic, not chronological):
| Category | Contains |
|----------|---------|
| `delegation` | Patterns about when/how to delegate, sub-agent prompt quality |
| `frontend` | UI/component patterns, styling, layout decisions |
| `backend` | API, database, server patterns |
| `testing` | Test patterns, coverage gaps, E2E strategies |
| `architecture` | Structural decisions, module boundaries |
| `anti-patterns` | Things that went wrong — highest priority for retrieval |
| `user-preferences` | User-specific workflow, style, and tool preferences |

### Learning Format (compact — 5-8 lines max)

```
mem_save({
  title: "Learning: {short descriptive title}",
  type: "learning",
  scope: "project",
  project: "{project}",
  topic_key: "learnings/{project}/{category}/{short-id}",
  content: `
    ## Learning: {title}
    **Category**: {category} · **Severity**: HIGH/MEDIUM/LOW
    **Source**: {observation IDs or session markers that produced this}
    **Pattern**: {when this applies — the trigger condition, 1 line}
    **Rule**: {what to do or not do, 1-2 lines}
    **Evidence**: {what happened that taught us this, 1 line}
  `
})
```

### Consolidation Rules (applied by `/improve`)

1. Group pending observations by THEME (not by session/step)
2. For each theme with **2+ observations**: create or update a consolidated learning
3. For each theme with **1 observation + HIGH severity**: create learning immediately
4. For each theme with **1 observation + LOW/MEDIUM severity**: wait for recurrence (leave observation as pending)
5. When updating an existing learning: merge evidence, update severity if pattern is stronger
6. Mark source observations as `applied` (never delete — audit trail)

**Data reduction target**: 10 sessions × 7 steps = 70 observations → consolidate into 5-15 learnings

### Learning Retrieval Strategy (baked into pipeline)

The orchestrator retrieves learnings at specific pipeline steps — never loads ALL learnings at once.

| Pipeline Step | Search Query | Purpose |
|---------------|-------------|---------|
| TRIAGE | `mem_search("learnings/{project}/anti-patterns")` + `mem_search("learnings/{project}")` | Surface known failures and relevant rules BEFORE planning |
| PLAN | `mem_search("learnings/{project}/{task-categories}")` | Pull category-specific learnings based on task type |
| DELEGATE | Inject relevant learnings into sub-agent `## Standards` | Sub-agents benefit from past learnings |
| COLLECT | `mem_search("learnings/{project}/anti-patterns")` | Validate results against known failure patterns |

**Context budget**: Each learning is ~50 tokens. Loading 3-5 relevant learnings = 150-250 tokens. This is manageable even in a constrained context window.

### Learning Lifecycle

```
Raw Observations (per-step, per-session)
    ↓ /improve consolidates
Consolidated Learnings (per-category, cross-session)
    ↓ /improve promotes (when learning is validated across 3+ sessions)
Framework Rules (SKILL.md, permanent)
```

Promotion criteria: a learning that has been validated across 3+ sessions with HIGH severity and consistent application should be proposed for promotion to a SKILL.md rule.

---

## /audit [target]

Analyzes one or more sessions for autoSDD compliance.

### Target Resolution
| User says | Resolve to |
|-----------|-----------|
| `last` | Most recent .jsonl in current project's sessions dir |
| `last-N` | N most recent .jsonl files |
| `{session-id}` | Specific session file |
| `project:{name}` | All sessions in `~/.claude/projects/C--Users-*-{name}/` |

Session logs live at: `~/.claude/projects/{project-slug}/{session-id}.jsonl`

### Analysis Steps

1. **Read JSONL** — each line is a JSON object. Focus on:
   - Lines with `"type": "assistant"` containing tool_use blocks
   - Tool names: `Agent`, `Write`, `Edit`, `Read`, `Bash`, `Skill`, MCP tools

2. **Extract Metrics**:
   ```
   tasks_delegated: count of Agent tool calls
   tasks_inline: count of Write/Edit calls on source files (.ts, .tsx, .prisma, .py, .go, .css)
   sub_agents_with_skills: count of Agent prompts containing "## Standards" or "## Project Standards"
   sub_agents_with_model: count of Agent calls with "model" parameter
   sub_agents_with_crea: count of Agent prompts with "## Context" AND "## Role" AND "## Task"
   re_delegations: count of Agent calls for same task (same description, different ID)
   engram_saves: count of mem_save tool calls
   engram_searches: count of mem_search/mem_context calls
   observation_saves: count of mem_save calls with topic_key matching "telemetry/obs/*"
   compactions: count of compaction markers in the log
   feedback_items: count of user corrections detected
   skill_reads: count of Read calls to SKILL.md files
   feedback_questions_asked: count of proactive questions asked to user (target: >= 1 per completed feature)
   feedback_md_generated: count of feedback.md files created at version close (target: 1 per version)
   learning_retrievals: count of mem_search calls with "learnings/" in the query
   ```

3. **Search Engram for Session Observations**:
   - `mem_search("telemetry/obs/{project}")` to find all observations for the target project
   - Filter by session marker if targeting a specific session
   - These observations provide RICHER context than JSONL alone (they capture the orchestrator's self-assessment at each step)

4. **Compare with prompt.md**:
   - Read `context/appVersions/v*/prompt.md` for versions worked on in the session
   - Check: were Tasks from prompt.md actually delegated? Or done inline?
   - Check: were Skills listed per task actually injected into sub-agents?
   - Check: was the Close Checklist completed?

5. **Generate Report**:
   ```markdown
   # Audit Report — Session {id}
   Date: {date}
   Project: {name}
   Observations Found: {N} (from Engram)

   ## Compliance Score: {0-100}

   ## Metrics
   | Metric | Value | Expected | Status |
   |--------|-------|----------|--------|
   | Tasks delegated | {N} | {from prompt.md} | OK/FAIL |
   | Tasks inline | {N} | 0 | OK/FAIL |
   | Skill injection rate | {%} | >= 80% | OK/FAIL |
   | Model param rate | {%} | 100% | OK/FAIL |
   | CREA compliance | {%} | >= 80% | OK/FAIL |
   | Engram proactive saves | {N} | >= 5 | OK/FAIL |
   | Session observations saved | {N} | >= 4 (one per major step) | OK/FAIL |
   | feedback.md generated | yes/no | yes | OK/FAIL |
   | Feedback questions asked | {N} | >= 1/feature | OK/FAIL |
   | feedback.md generated | {yes/no} | yes per version | OK/FAIL |
   | Learning retrievals | {N} | >= 1 at triage | OK/FAIL |

   ## Session Observations Summary
   {aggregated from Engram observations — deviations, friction points, what worked}

   ## Anti-Patterns Detected
   - {list of orchestrator violations: inline code writing, missing skills, etc.}

   ## Recommendations
   - {prioritized list of what to fix in the framework or SKILL.md}
   ```

6. **Save to Engram**: `mem_save(topic_key: "telemetry/audit/{session-id}")`

---

## Feedback Compliance Audit

Missing feedback is a critical framework violation. `/audit` and `/self-analysis` MUST check:

### Automated Checks
1. **feedback.md existence**: For each version folder in `context/appVersions/v*/`, verify `feedback.md` exists
2. **feedback.md quality**: Each feedback.md must contain:
   - `## Telemetry` section with all metrics from SKILL.md Section 8
   - `## Discoveries + User Feedback` table with at least 1 entry
3. **Proactive questions**: Search JSONL for evidence of feedback questions asked to user
   - Pattern: assistant messages containing "?" directed at user (not rhetorical)
   - Target: >= 1 per completed feature

### Validation Script
At CLOSE (Step 6), the orchestrator SHOULD verify:
```bash
# Check feedback.md exists for current version
test -f "context/appVersions/v${VERSION}/feedback.md" && echo "OK" || echo "MISSING feedback.md"
```

### Common Causes of Missing Feedback
- **Segmented versions**: When a large change is split into multiple versions, feedback.md must be generated for EACH version, not just the last one
- **Context compaction**: If feedback.md was planned but context was compacted before CLOSE, it gets lost. Fix: save feedback draft to Engram BEFORE compaction
- **Pipeline skip**: Agent jumps from DELEGATE directly to next task without COLLECT/CLOSE. Fix: Pipeline Gates in CLAUDE.md enforce step ordering

---

## /improve [target]

Runs `/audit` then generates actionable improvement plan using BOTH JSONL analysis AND Engram observations.

### Steps

1. **Search Engram for pending observations**:
   ```
   mem_search("telemetry/obs") with filter for Status: pending
   ```
   This is the PRIMARY input — observations capture what the orchestrator actually experienced.

2. **Execute `/audit`** on target sessions (JSONL analysis provides quantitative metrics)

3. **Consolidate observations into learnings**:
   - Group pending observations by THEME (what do they have in common?)
   - For each theme: apply Consolidation Rules (see Consolidated Learning Protocol)
   - Create/update learning entries in Engram using the Learning Format
   - This is the DATA REDUCTION step: many observations → few learnings

4. **Aggregate findings** across all sources:
   - Newly created/updated consolidated learnings
   - Engram observations (qualitative: friction, gaps, what worked)
   - JSONL audit metrics (quantitative: counts, rates, scores)
   - Prior improvement plans: `mem_search("telemetry/improvement-plan")`

5. **Identify patterns**: What consistently fails? What consistently works? What's new?

6. **Generate improvement plan**:
   ```markdown
   # Improvement Plan — Based on {N} sessions, {M} observations

   ## What's Working
   - {patterns that consistently score well}

   ## What's Failing
   | Issue | Frequency | Root Cause | Proposed Fix |
   |-------|-----------|-----------|-------------|
   | {issue} | {N/N sessions} | {why} | {concrete change to SKILL.md section X} |

   ## Observations Consumed
   | Session | Step | Key Finding | Action |
   |---------|------|------------|--------|
   | {marker} | {step} | {finding} | {what will change} |

   ## Proposed Changes (requires user approval)
   1. {specific edit to SKILL.md section X}
   2. {specific edit to CLAUDE.md}
   3. {skill to add/remove}

   ## LEARNING.md Entry (to be appended after approval)
   {draft entry for the consolidated changelog}
   ```

7. **Ask user**: "Aplico estos cambios?"

8. **On approval — execute all post-improvement actions**:
   a. Apply changes to SKILL.md / CLAUDE.md / skills
   b. Mark consumed observations as "applied":
      ```
      mem_update({
        id: {observation-id},
        content: {original content with Status: pending → Status: applied, Applied: {date} - {improvement-id}}
      })
      ```
   c. Append entry to `LEARNING.md` (see LEARNING.md Protocol below)
   d. Save improvement plan to Engram: `telemetry/improvement-plan/{date}`

9. **On rejection**: Save as `telemetry/improvement-plan/{date}-rejected` with user's reasoning. Do NOT mark observations as applied.

---

## LEARNING.md Protocol

`LEARNING.md` lives at the root of the autoSDD repo. It is the consolidated changelog of everything the framework has learned from real-world usage.

### Entry Format (INDEX — details live in Engram)

```markdown
## {YYYY-MM-DD} — {short title}

**Source**: {session markers} · **Observations consumed**: {count} · **Sections affected**: {SKILL.md Section N}

### Learnings Created/Updated
| Category | Engram Key | Severity | Summary |
|----------|-----------|----------|---------|
| {cat} | `learnings/{project}/{cat}/{id}` | HIGH/MED/LOW | {1-line} |

### Changes Applied
- {specific change 1}
- {specific change 2}
```

### Why an Index?
LEARNING.md is a human-readable AUDIT TRAIL — it records WHEN learnings were created and WHAT changed. The actual learning content lives in Engram (`learnings/{project}/{category}/{id}`), where it's retrievable by category during pipeline execution. This keeps LEARNING.md small forever while Engram handles the retrieval.

### Rules
- Entries are appended chronologically (newest at bottom)
- Each entry links back to the observations that produced it
- LEARNING.md is the human-readable audit trail — Engram observations are the machine-readable one
- After appending, commit LEARNING.md alongside any SKILL.md changes

---

## /self-analysis

In-session self-audit against v5.0 checkpoints. See `context/questions.md` for the full protocol.

### Quick Summary

1. Answer sections A-H with EVIDENCE from the session
2. Rate each: DONE / PARTIAL / NOT DONE
3. Ask user 5 mandatory feedback questions (Section F) — STOP and WAIT
4. Generate structured report (Section G1) + Engram save (Section G2)
5. Self-assessment (Section H)

### Integration with Observation Protocol

If session observations were saved during the session (as they should be), `/self-analysis` should:
1. `mem_search("telemetry/obs/{project}/{session-marker}")` to retrieve them
2. Use them as evidence for sections A-E (they contain per-step compliance data)
3. Flag any missing observations (steps where no observation was saved = compliance gap)

---

## Inline Telemetry (for orchestrator during execution)

The orchestrator tracks counters during a session. With the observation protocol, these are now PERSISTED to Engram at each step — not just counted mentally.

Quick self-check template (run at each pipeline step AND at version close):
- "How many Agent calls did I make?" → tasks_delegated
- "Did I Write/Edit any .ts/.tsx files directly?" → tasks_inline (should be 0)
- "Did my Agent prompts have ## Standards sections?" → skill_injection_rate
- "Did I call mem_save proactively?" → engram_saves
- "Did I save an observation for this step?" → observation_saves (should match steps completed)

---

*autosdd-telemetry v2.1.0 — April 2026 · Observation-driven self-improvement*
