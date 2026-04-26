---
name: autosdd-telemetry
description: >
  Analyzes AI agent session logs to measure autoSDD framework compliance,
  detect orchestrator anti-patterns, and generate improvement recommendations.
  Triggered by /audit and /improve commands.
version: "1.0.0"
---

# autosdd-telemetry — Session Analysis and Self-Improvement

## When to Use
- User says "dame las oportunidades de mejora", "/audit", "/improve"
- User provides session IDs or says "last", "last-3", "project:name"
- At version close, for generating telemetry section of feedback.md

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
   Date: {date}
   Project: {name}

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
   - {list of orchestrator violations: inline code writing, missing skills, etc.}

   ## Recommendations
   - {prioritized list of what to fix in the framework or SKILL.md}
   ```

5. **Save to Engram**: `mem_save(topic_key: "telemetry/audit/{session-id}")`

## /improve [target]

Runs `/audit` then generates actionable improvement plan.

### Steps
1. Execute `/audit` on target sessions
2. Aggregate metrics across sessions (if multiple)
3. Compare against SKILL.md expectations
4. Identify patterns: what consistently fails? What works?
5. Generate improvement plan:
   ```markdown
   # Improvement Plan — Based on {N} sessions

   ## What's Working
   - {patterns that consistently score well}

   ## What's Failing
   | Issue | Frequency | Root Cause | Proposed Fix |
   |-------|-----------|-----------|-------------|
   | {issue} | {N/N sessions} | {why} | {concrete change to SKILL.md or CLAUDE.md} |

   ## Proposed Changes (requires user approval)
   1. {specific edit to SKILL.md section X}
   2. {specific edit to CLAUDE.md}
   3. {skill to add/remove}
   ```
6. Save to Engram: `telemetry/improvement-plan/{date}`
7. Ask user: "Aplico estos cambios?"

## Inline Telemetry (for orchestrator during execution)

The orchestrator should track these counters mentally during a session and include them in feedback.md at version close. No external tooling needed — just count your own tool calls.

Quick self-check template (run mentally at version close):
- "How many Agent calls did I make?" → tasks_delegated
- "Did I Write/Edit any .ts/.tsx files directly?" → tasks_inline (should be 0)
- "Did my Agent prompts have ## Standards sections?" → skill_injection_rate
- "Did I call mem_save proactively?" → engram_saves
