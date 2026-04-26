---
name: feedback-report
description: >
  Generates feedback reports analyzing prompt quality, skill gaps, token efficiency,
  and AI/user improvement trends across versions or time periods. Produces actionable
  recommendations for both the user (prompt improvement) and the AI (self-correction).
version: "1.0.0"
license: MIT
metadata:
  author: gentleman-programming
  repository: https://github.com/thestark77/autosdd
  requires:
    - autoSDD framework (active)
    - Engram MCP (for cross-session data)
  compatible_agents:
    - Claude Code
    - Cursor
    - Windsurf
---

# Feedback Report — Skill

> Generates AI↔User feedback reports for continuous improvement.

## Trigger

Activated when:
- User invokes `/feedback [timerange]`
- Orchestrator requests a feedback report after version close
- User asks "how am I doing?", "give me feedback", "dame feedback", "qué puedo mejorar?"

## Commands

| Command | Description |
|---------|------------|
| `/feedback` | Feedback for the last completed version |
| `/feedback week` | Aggregate feedback for the last 7 days |
| `/feedback month` | Aggregate feedback for the last 30 days |
| `/feedback v1.0.0..v2.0.0` | Feedback for a specific version range |
| `/feedback all` | Full historical analysis (token-heavy, use sparingly) |

## Data Sources

Read these in order of priority (stop when you have enough data):

1. **Version feedback files**: `context/appVersions/v*/feedback.md` — pre-generated per-version reports
2. **Engram prompt analysis**: `mem_search(query: "feedback/prompt-analysis", project: "{project}")` — individual prompt insights
3. **Engram user patterns**: `mem_search(query: "feedback/user-patterns", project: "{project}")` — accumulated user skill gaps
4. **Version metrics**: `context/appVersions/v*/metrics.md` — token usage, outcome scores
5. **Engram corrections**: `mem_search(query: "feedback/corrections", project: "{project}")` — user feedback to AI

## Token Efficiency Rules

- NEVER read full version files. Read only `feedback.md` and `metrics.md` per version (small files).
- For time-based reports, filter versions by date BEFORE reading any files.
- For `/feedback all`, read only Engram aggregates — do NOT scan all version folders.
- Cap output at 150 lines. Link to individual version feedback for details.

## Report Schema

### Single Version Report

```markdown
# Feedback Report — {version}
Generated: {date}

## Prompt Quality Score: {score}/100

## AI → User: What You Can Improve

### Strengths
- {what the user did well in this version's prompts}

### Areas for Improvement
| Area | Issue | How to Fix |
|------|-------|-----------|
| {category} | {specific issue} | {actionable suggestion} |

### Skill Gaps Detected
- **{skill}**: {evidence from this version} → {learning recommendation}

### Token Efficiency
- Tokens used: {total}
- Estimated waste from ambiguous prompts: {amount} ({percentage}%)
- Self-correction cycles: {count}

## User → AI: Feedback Received
| When | What | Action Taken |
|------|------|-------------|
| {phase} | {user feedback} | {what was updated} |

## AI Self-Assessment
- What went well: {description}
- What could improve: {description}
- Changes made to memory/guidelines: {list}
```

### Aggregate Report (week/month/range)

```markdown
# Feedback Report — {period}
Generated: {date}

## Versions Analyzed: {count} ({range})

## User Growth Trajectory
- Average prompt quality: {start_score}/100 → {end_score}/100 ({trend})
- Most improved area: {area} (+{points} points)
- Needs attention: {area} (consistently {low/medium})

## Recurring Skill Gaps (sorted by frequency)
| Gap | Frequency | Impact | Recommended Learning |
|-----|-----------|--------|---------------------|
| {gap} | {n}/{total} versions | {HIGH/MEDIUM/LOW} | {specific resource or practice} |

## Token Efficiency Trends
- Total tokens: {sum}
- Average waste per version: {avg} ({percentage}%)
- Top token wasters:
  1. {pattern} ({count} occurrences, ~{tokens} tokens wasted)

## AI Self-Improvement Log
| What Changed | Source | Version | Impact |
|-------------|--------|---------|--------|
| {change} | {user feedback / agent discovery} | {version} | {description} |

## Recommendations
1. **Immediate**: {actionable, specific}
2. **This week**: {learning goal}
3. **This month**: {skill development area}
```

## Skill Gap Categories

Use these standard categories for consistent tracking:

| Category | Signals |
|----------|---------|
| Context completeness | Missing file paths, stack info, existing patterns |
| Architecture awareness | Violates established patterns, flat structures, tight coupling |
| Security awareness | No input validation, missing auth checks, SQL injection risk |
| Testing awareness | No tests requested for critical changes |
| Database design | Denormalization, missing indexes, no constraints |
| Error handling | No error cases, no fallbacks, no validation |
| Performance awareness | N+1 queries, unnecessary re-renders, missing pagination |
| Specificity | Vague instructions, "make it good", undefined acceptance criteria |
| Token efficiency | Overly verbose prompts, repeated context, unnecessary detail |

## Persistence

After generating any report:
1. Save to `context/feedback-reports/{period}.md` (file-based, committable)
2. Save aggregate to Engram: `mem_save(topic_key: "feedback/report/{period}", ...)`
3. Update user patterns: `mem_save(topic_key: "feedback/user-patterns/{username}", ...)` with any new skill gaps
