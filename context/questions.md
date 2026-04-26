# autoSDD v5.0 — Session Self-Analysis Protocol

> **Purpose**: Paste this prompt after the agent finishes executing its plan. The agent self-analyzes against v5.0 checkpoints, solicits user feedback, and generates artifacts consumable by `/improve` in future sessions.
>
> **Trigger**: User pastes this content, or agent receives `/self-analysis` command.

---

## Instructions

You just finished executing a plan under autoSDD v5.0. Perform a structured self-analysis NOW.

**Rules**:
1. Answer EVERY section with EVIDENCE from this session — quote your tool calls, prompts, decisions
2. Rate each: **DONE** (with evidence) · **PARTIAL** (what was missed) · **NOT DONE** (acknowledge)
3. Be brutally honest — this analysis improves the framework
4. After analysis, ask the user for feedback (Section F)
5. Generate artifacts (Section G)
6. Do NOT speculate about what you "would have done" — only report what you ACTUALLY DID

---

## A. Pipeline Compliance (autoSDD Steps 1-8)

### A1. TRIAGE (Step 1)
- [ ] Called `mem_search` for pending tasks FIRST
- [ ] Assessed prompt clarity: HIGH / MEDIUM / LOW
- [ ] Checked agent + user TODO lists for relevant items
- [ ] Asked for references when they would improve execution
- Evidence: ___

### A2. ROUTE (Step 2)
- [ ] Selected correct flow: DEV / DEBUG / REVIEW / RESEARCH
- Evidence: ___

### A3. PLAN — CREA on prompt.md (Step 3)
- [ ] Created prompt.md with Context · Role · Specificity · Tasks
- [ ] CREA applied ONCE on prompt.md (not per sub-agent, not on raw user prompt)
- [ ] Context includes: current state, problem + WHY, guidelines.md constraints, Engram context, references
- [ ] Tasks specify: type (parallel/depends), skills, MCPs, files, model, validation
- [ ] Commits section + close checklist present
- Evidence: ___

### A4. DELEGATE (Step 4)
- [ ] Used Agent tool (not inline Write/Edit) for all implementation
- [ ] Sub-agent prompts follow Section 4 launch template
- [ ] Skill rules injected as TEXT in `## Standards (auto-resolved)` — NOT file paths
- [ ] `model` parameter set on every Agent call
- [ ] Validation commands specified (tsc, eslint, tests)
- [ ] `## Return Contract` present
- Evidence: ___

### A5. COLLECT (Step 5)
- [ ] Validated results via delegated agents (not manual review)
- [ ] Reviewed TODO list
- [ ] Reminded user of pending feedback questions
- Evidence: ___

### A6. CLOSE VERSION (Step 6)
- [ ] Generated feedback.md in version folder with telemetry metrics
- [ ] Updated PROGRESS.md
- [ ] Saved Engram summary to `feedback/version-report/{version}`
- Evidence: ___

### A7. KNOWLEDGE UPDATE (Step 7)
- [ ] Updated context files (guidelines.md, user_context.md, business_logic.md) if anything changed
- [ ] Saved discoveries to Engram proactively
- Evidence: ___

### A8. COMPACTION CHECK (Step 8)
- [ ] Monitored context window usage
- [ ] Suggested /compact at milestones when > 50%
- [ ] Persisted Engram summary + plan BEFORE suggesting compaction
- [ ] After compaction: recovered via `mem_context` → re-read Sections 1-4
- Evidence: ___

---

## B. Orchestrator Boundary (SKILL.md Section 1)

### B1. Inline Work Audit
List EVERY Write/Edit you performed on source files (.ts, .tsx, .prisma, .css, .py, .go):

| # | Action (Write/Edit) | File | Justification | Should have delegated? |
|---|---------------------|------|---------------|----------------------|

Acceptable inline: prompt.md · feedback.md · PROGRESS.md · git commands · single-line mechanical edits (version bump, import typo).

### B2. Sub-Agent Failure Recovery
- Sub-agents that failed: {count}
- Recovery: DIAGNOSE → IMPROVE prompt → RE-DELEGATE? Or coded inline?
- After 2 failures on same task: asked user?

---

## C. CREA Quality (SKILL.md Section 3)

For EACH prompt.md created:

| Version | Context | Role | Specificity | Tasks | Commits | Checklist | Score /100 |
|---------|---------|------|-------------|-------|---------|-----------|-----------|
| v{X.Y.Z} | ✓/✗ | ✓/✗ | ✓/✗ | ✓/✗ | ✓/✗ | ✓/✗ | {score} |

---

## D. Sub-Agent Quality (SKILL.md Section 4)

For EACH Agent tool call:

| # | Description | ## Context | ## Role | ## Standards | ## Task | ## Validation | ## Return | model param |
|---|-------------|-----------|---------|-------------|---------|--------------|-----------|------------|
| 1 | {name} | ✓/✗ | ✓/✗ | ✓/✗ | ✓/✗ | ✓/✗ | ✓/✗ | ✓/✗ |

### Skill Routing (SKILL.md Section 5)
| Task | Expected Skills (per routing table) | Actually Injected | Match? |
|------|-------------------------------------|-------------------|--------|

Were rules injected as TEXT or as file path references?

---

## E. Engram & Feedback Compliance

### E1. Memory Protocol (SKILL.md Section 6)
- [ ] `mem_search` called on EVERY prompt (not just session start)
- [ ] Checked `pending/{project}` and `pending/general` topic keys
- [ ] Proactive saves (count: ___). List topic keys used.
- [ ] **Session observations saved** at each pipeline step (topic key: `telemetry/obs/{project}/{session-marker}/{step}`). Count: ___
- [ ] Session summary saved with: Goal · Discoveries · Accomplished · Pending Items · Next Steps

### E2. Feedback Detection (SKILL.md Section 9)
- User corrections detected: {count}
- Each classified (technical / style / agent error)? ___
- Each persisted to context files + Engram? ___
- Confirmation given ("Anotado. [summary].")? ___
- Proactive questions asked: {count} (max 2/phase rule respected?)
- Answers persisted to user_context.md + Engram? ___

---

## F. User Feedback (ASK THESE NOW — MANDATORY)

**Pause here. Ask the user these questions and WAIT for their response.**

1. "¿La delegación fue efectiva? ¿Los sub-agentes entregaron resultados de calidad?"
2. "¿Hubo algún momento donde no entendí lo que pedías, o me fui por otro camino?"
3. "¿El resultado final cumple con lo que necesitabas? Si no, ¿qué falta?"
4. "¿Algo que hice bien que debería seguir haciendo en futuras sesiones?"
5. "¿Algo que hice mal que NO debo repetir?"

If the user doesn't answer all questions or says to continue, proceed with what you have.
Save ALL feedback to Engram: `feedback/user/{project}/{date}`

---

## G. Artifact Generation (MANDATORY — after F)

Generate TWO outputs:

### G1. Structured Session Report

Write to `context/appVersions/session-{YYYY-MM-DD}-analysis.md`:

```markdown
# Session Analysis — {date}
> Session: {id} · Project: {name} · Framework: autoSDD v5.0
> Compliance Score: {0-100}

## Telemetry
tasks_delegated={N} · tasks_inline={N} · sub_agents_with_skills={N}
sub_agents_with_model={N} · re_delegations={N} · engram_saves={N}
compactions={N} · user_feedback_items={N} · triage_score={H/M/L}

## Pipeline Compliance
| Step | Status | Notes |
|------|--------|-------|
| 1. Triage | DONE/PARTIAL/NOT DONE | {1-line} |
| 2. Route | ... | ... |
| 3. Plan (CREA) | ... | ... |
| 4. Delegate | ... | ... |
| 5. Collect | ... | ... |
| 6. Close | ... | ... |
| 7. Knowledge | ... | ... |
| 8. Compaction | ... | ... |

## Orchestrator Violations
{list source files written inline — empty if compliant}

## Anti-Patterns Detected
{bulleted list of framework deviations}

## User Feedback Summary
{condensed responses from Section F}

## Improvement Opportunities (tagged by SKILL.md section)
| Priority | SKILL.md Section | Issue | Proposed Fix |
|----------|-----------------|-------|-------------|
| HIGH | Section {N} | {specific issue} | {concrete change to SKILL.md} |

## Discoveries
{non-obvious learnings, conventions, gotchas worth preserving}
```

### G2. Engram Save

Call `mem_save` with topic key `telemetry/session-analysis/{project}/{date}`:
- Compliance score + top 3 compliance gaps
- User feedback summary (condensed)
- Top 3 improvement opportunities with SKILL.md section tags
- Key discoveries

This entry is what `/improve` consumes across sessions to derive framework changes.

---

## H. Self-Assessment (Final)

1. Overall compliance score (0-100): ___
2. #1 reason for deviating from the framework: ___
3. Was the framework unclear or impractical in any specific way? ___
4. If you could redo this session, what would you change? ___
5. What single change to SKILL.md would have the highest impact? ___

---

*autoSDD v5.0 · Self-Analysis Protocol · questions.md*
