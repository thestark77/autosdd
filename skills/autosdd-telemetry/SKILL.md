---
name: autosdd-telemetry
description: >
  Analyzes AI agent session logs to measure autoSDD framework compliance,
  detect orchestrator anti-patterns, and generate improvement recommendations.
  Triggered by /audit, /improve, and /self-analysis commands.
version: "2.0.0"
---

# autosdd-telemetry — Session Analysis and Self-Improvement

## When to Use
- User says "dame las oportunidades de mejora", "/audit", "/improve", "/self-analysis"
- User provides session IDs or says "last", "last-3", "project:name"
- At version close, for generating telemetry section of feedback.md
- After completing a plan execution (self-analysis)

---

## /audit [target]

Analyzes one or more sessions for autoSDD compliance via JSONL log inspection (post-hoc).

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
   compactions: count of compaction markers in the log
   feedback_items: count of user corrections detected
   skill_reads: count of Read calls to SKILL.md files
   ```

3. **Compare with prompt.md**:
   - Read `context/appVersions/v*/prompt.md` for versions worked on in the session
   - Check: were Tasks from prompt.md actually delegated? Or done inline?
   - Check: were Skills listed per task actually injected into sub-agents?
   - Check: was the Close Checklist completed?

4. **Generate Report**:
   ```markdown
   # Audit Report — Session {id}
   Date: {date} · Project: {name}

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
   | feedback.md generated | yes/no | yes | OK/FAIL |

   ## Anti-Patterns Detected
   - {list of orchestrator violations}

   ## Recommendations
   - {prioritized list of improvements}
   ```

5. **Save to Engram**: `mem_save(topic_key: "telemetry/audit/{session-id}")`

---

## /self-analysis

In-session self-analysis — the agent evaluates ITS OWN session against v5.0 checkpoints while it still has full context. More accurate than post-hoc `/audit` because the agent has direct access to its reasoning and decisions.

### When to Trigger
- User pastes the content of `context/questions.md` (the self-analysis protocol)
- User says `/self-analysis` or "analizate", "hacé tu feedback", "self-audit"
- Agent proactively at session end (optional, only if user has shown interest in dogfooding)

### Protocol

The full protocol is defined in `context/questions.md` in the autoSDD repository. Summary of sections:

1. **Pipeline Compliance (A)**: Check each of Steps 1-8 with evidence
2. **Orchestrator Boundary (B)**: Audit inline vs delegated work
3. **CREA Quality (C)**: Score each prompt.md created
4. **Sub-Agent Quality (D)**: Evaluate every Agent call against Section 4 template
5. **Engram & Feedback (E)**: Memory usage and feedback detection compliance
6. **User Feedback (F)**: **MANDATORY** — ask user 5 specific questions about session quality. WAIT for response before continuing.
7. **Artifact Generation (G)**: Write structured session report + Engram save
8. **Self-Assessment (H)**: Honest reflection on compliance, deviations, and framework gaps

### Artifact Output

**File**: `context/appVersions/session-{YYYY-MM-DD}-analysis.md`
- Compliance score (0-100)
- Telemetry metrics (same as feedback.md)
- Pipeline compliance table (status per step)
- Orchestrator violations list
- Anti-patterns detected
- User feedback summary
- Improvement opportunities table — tagged by SKILL.md section, with priority and concrete proposed fixes
- Discoveries worth preserving

**Engram**: `telemetry/session-analysis/{project}/{date}`
- Compliance score + top 3 gaps
- User feedback condensed
- Top 3 improvements with SKILL.md section tags

### Cross-Session Consumption

These artifacts are designed for `/improve` to consume across multiple sessions:
- **SKILL.md section tags** let `/improve` know WHERE to apply changes
- **Concrete proposed fixes** (not vague suggestions) make changes actionable
- **Priority ranking** (HIGH/MED/LOW) indicates impact: HIGH = framework consistently ignored in this area
- **Pattern detection**: if the same issue appears across multiple session analyses, it's HIGH priority

---

## /improve [target]

Runs `/audit` (or reads existing session analyses) then generates actionable improvement plan.

### Input Sources
`/improve` consumes from ANY of these:
1. **Post-hoc audits**: `/audit` reports saved to Engram at `telemetry/audit/{id}`
2. **In-session analyses**: `/self-analysis` artifacts at `telemetry/session-analysis/{project}/{date}`
3. **Version feedback**: `feedback/version-report/{version}` from Step 6 close
4. **User feedback**: `feedback/user/{project}/{date}` from Section 9

### Steps
1. Search Engram for all relevant telemetry entries (filter by project if specified)
2. Aggregate metrics and patterns across sessions
3. Compare against current SKILL.md expectations
4. Identify PATTERNS: what consistently fails? What works?
5. Generate improvement plan:
   ```markdown
   # Improvement Plan — Based on {N} sessions
   > Generated: {date} · Project scope: {project or "all"}

   ## What's Working
   - {patterns that consistently score well — KEEP these}

   ## What's Failing
   | Issue | Frequency | SKILL.md Section | Root Cause | Proposed Fix |
   |-------|-----------|-----------------|-----------|-------------|
   | {issue} | {N/N sessions} | Section {X} | {why} | {concrete edit} |

   ## Proposed Changes (requires user approval)
   1. {specific edit to SKILL.md Section X, line Y}
   2. {specific edit to CLAUDE.md template}
   3. {skill to add/remove/modify}

   ## User Feedback Trends
   {patterns from user feedback across sessions}
   ```
6. Save to Engram: `telemetry/improvement-plan/{date}`
7. Ask user: "Aplico estos cambios?" — NEVER apply without approval

---

## Inline Telemetry (for orchestrator during execution)

Track these counters mentally during a session — include in feedback.md at version close:

- "How many Agent calls did I make?" → tasks_delegated
- "Did I Write/Edit any source files directly?" → tasks_inline (target: 0)
- "Did my Agent prompts have ## Standards sections?" → skill_injection_rate
- "Did I set model on every Agent call?" → model_param_rate
- "Did I call mem_save proactively?" → engram_saves

---

## Dogfooding Loop

autoSDD uses itself to develop itself. The full feedback loop:

1. **Execute**: Agent runs autoSDD v{current} on a real project
2. **Analyze**: At session end, run `/self-analysis` (or paste `questions.md`)
3. **Collect feedback**: Agent asks user 5 structured questions, persists answers
4. **Generate artifacts**: Session report + Engram entries
5. **Improve**: In a NEW session on the autoSDD repo, run `/improve project:{name}` or `/improve last-N`
6. **Apply**: `/improve` reads all telemetry, identifies patterns, proposes SKILL.md changes
7. **Validate**: User approves changes → new autoSDD version → repeat from step 1

The key principle: improvement decisions are data-driven from real execution, not speculative.

---

*autosdd-telemetry v2.0.0 — April 2026*
