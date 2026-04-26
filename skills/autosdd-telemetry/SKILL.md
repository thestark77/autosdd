---
name: autosdd-telemetry
description: >
  Analyzes AI agent session logs to measure autoSDD framework compliance,
  detect orchestrator anti-patterns, and generate improvement recommendations.
  Manages session observations lifecycle and consolidated learning changelog.
  Triggered by /audit, /improve, and /self-analysis commands.
version: "2.0.0"
---

# autosdd-telemetry v2.0 — Session Analysis, Observations & Self-Improvement

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

   ## Session Observations Summary
   {aggregated from Engram observations — deviations, friction points, what worked}

   ## Anti-Patterns Detected
   - {list of orchestrator violations: inline code writing, missing skills, etc.}

   ## Recommendations
   - {prioritized list of what to fix in the framework or SKILL.md}
   ```

6. **Save to Engram**: `mem_save(topic_key: "telemetry/audit/{session-id}")`

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

3. **Aggregate findings** across all sources:
   - Engram observations (qualitative: friction, gaps, what worked)
   - JSONL audit metrics (quantitative: counts, rates, scores)
   - Prior improvement plans: `mem_search("telemetry/improvement-plan")`

4. **Identify patterns**: What consistently fails? What consistently works? What's new?

5. **Generate improvement plan**:
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

6. **Ask user**: "Aplico estos cambios?"

7. **On approval — execute all post-improvement actions**:
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

8. **On rejection**: Save as `telemetry/improvement-plan/{date}-rejected` with user's reasoning. Do NOT mark observations as applied.

---

## LEARNING.md Protocol

`LEARNING.md` lives at the root of the autoSDD repo. It is the consolidated changelog of everything the framework has learned from real-world usage.

### Entry Format

```markdown
## {YYYY-MM-DD} — {short title}

**Source**: {session markers or audit IDs that contributed}
**Observations consumed**: {count}
**Sections affected**: {SKILL.md Section N, ...}

### What We Learned
{2-4 sentences: the insight, pattern, or anti-pattern discovered}

### Changes Applied
- {specific change 1}
- {specific change 2}

### Impact
{expected improvement: "reduces inline code violations", "improves skill injection rate", etc.}
```

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

*autosdd-telemetry v2.0.0 — April 2026 · Observation-driven self-improvement*
