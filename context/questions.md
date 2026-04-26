# autoSDD v4 Orchestrator Diagnostic Audit

> **Purpose**: Evaluate whether the autoSDD v4 framework is being correctly executed by the orchestrator in this session.
> **How to use**: Paste this entire prompt into the ProHuella session (0ca9347b). The orchestrator will self-report against each checkpoint.

---

## Instructions

You are being audited. Answer EVERY question below with EVIDENCE from this session — quote your own tool calls, prompts you wrote, or decisions you made. Do NOT speculate about what you "would have done." Only report what you ACTUALLY DID.

For each section, answer with one of:
- **DONE** — with evidence (quote the exact tool call, prompt text, or action)
- **PARTIALLY** — explain what was done and what was missed
- **NOT DONE** — acknowledge the gap

Be brutally honest. This audit improves the framework — lying helps nobody.

---

## Section 1: Pipeline Execution (Steps 1-7 of autoSDD Core Behavior)

### 1.1 Prompt Analyst (Step 1)
- Did you generate a PromptInsights score (0-100) for the user's initial prompt?
- Did you check for: context completeness, ambiguity, architecture awareness, security awareness, testing awareness, specificity, token efficiency?
- If score was < 60, did you ask for clarification before proceeding?

### 1.2 Feedback Detector (Step 2)
- Did the user give you any corrections during the session? List each one.
- For each correction: did you classify it (technical correction / style preference / agent error)?
- Did you persist each correction to Engram immediately?
- Did you confirm to the user: "Anotado. Guarde que [X]. No va a pasar de nuevo."?

### 1.3 Flow Router (Step 3)
- What flow did you select (Dev, Debug, Review, Research, Self-Improve)?
- What was your confidence level?
- Did you document this routing decision anywhere?

### 1.4 CREA Prompt Refine (Step 4)
- Did you apply CREA (Context, Role, Specificity, Action) to restructure the user's prompt?
- Did you invoke or reference the `prompt-engineering-patterns` skill?
- Did you select specific techniques from that skill (Few-Shot, CoT, Structured Output, etc.)?

### 1.5 Flow Execution (Step 5)
- Which SDD phases did you execute? (INTAKE, PLAN, BUILD, VERIFY, CERTIFY, SHIP, REVIEW)
- For each phase: was it delegated to a sub-agent or executed inline?

### 1.6 Outcome Collection (Step 6)
- Did you track: tokens per phase, duration, outcome score, retry count?
- Did you create a metrics.md in any version folder?

### 1.7 Knowledge Update (Step 7)
- Did you update guidelines.md, user_context.md, or business_logic.md during the session?
- Did you save discoveries to Engram proactively (not just when asked)?

---

## Section 2: CREA Framework Compliance

### 2.1 prompt.md Files
For each version you created (v2.6.3, v2.6.4, v2.6.5, v2.6.6, v2.6.7):
- Does the prompt.md have explicit **Context** / **Role** / **Specificity** / **Action** sections?
- Does it specify which skills to use per task?
- Does it specify which MCPs/tools to use per task?
- Does it annotate tasks as parallel vs blocking?
- Does it reference Engram memories for prior context?

### 2.2 Sub-Agent Prompts
For EACH sub-agent you launched (list all of them):
- Quote the first 5 lines of the prompt you gave it
- Did it contain `## Project Standards (auto-resolved)` with compact rules?
- Did it contain `## Skills to Use` with explicit assignments?
- Did it specify a `model` parameter (per model-assignments.md)?
- Did it have CREA structure (Context, Role, Specificity, Action)?
- Did it specify which MCPs/tools the sub-agent should use?

---

## Section 3: Orchestrator vs Executor Boundary

### 3.1 Inline Work Audit
List EVERY action you performed INLINE (not delegated). For each:
- What was the action? (Read, Write, Edit, Bash)
- How many files did it touch?
- Should it have been delegated per the sdd-orchestrator protocol?

Per the protocol:
- Read 1-3 files to decide/verify = OK inline
- Read 4+ files to explore/understand = DELEGATE
- Write atomic (one file, mechanical) = OK inline
- Write with analysis (multiple files, new logic) = DELEGATE
- Bash for state (git, gh) = OK inline
- Bash for execution (test, build, install) = DELEGATE

### 3.2 Context Window Impact
- Approximately how many tool calls did you make inline?
- How many of those inflated your context window without being necessary for orchestration decisions?
- Did you hit a compaction during the session? If yes, what caused it?

### 3.3 Sub-Agent Failure Recovery
- Did any sub-agents fail or return incomplete results?
- When they did, did you: (a) re-delegate with a better prompt, or (b) do the work yourself inline?
- If (b), explain why you chose to do it inline instead of re-delegating.

---

## Section 4: Skill Management

### 4.1 Skill Activation
- Did you create any symlinks in `.claude/skills/` during the session?
- Did you read any SKILL.md files during the session? Which ones?
- Did you deactivate (remove symlinks) after task completion?

### 4.2 Skill Routing (per Section 10.1 of autoSDD)
For each task you executed, which skills SHOULD have been activated?
- v2.6.3 (Schema + Seeds): `postgresql-table-design`?
- v2.6.4 (API Layer): `error-handling-patterns`?
- v2.6.5+ (prompt.md creation): `prompt-engineering-patterns`?
- Were any of these actually used?

### 4.3 Skill Injection into Sub-Agents
- Did you search Engram for a skill registry (`mem_search(query: "skill-registry")`)?
- Did you cache compact rules from the skill registry?
- Did you inject `## Project Standards (auto-resolved)` into any sub-agent prompt?

---

## Section 5: Engram Memory Usage

### 5.1 Session Start
- Did you call `mem_context` at the start of the session?
- Did you call `mem_search` to check for prior work on the current task?
- Did you call `mem_save_prompt` with the user's initial prompt?

### 5.2 Proactive Saves
List EVERY `mem_save` call you made during the session:
- What was saved?
- Was it reactive (compaction/user request) or proactive (you decided to save)?

### 5.3 Session Close
- Did you call `mem_session_summary` before ending?
- If not, what is the current state that would be lost without it?

---

## Section 6: Version Close Protocol

For each COMPLETED version (v2.6.3, v2.6.4):
- Did you generate a `feedback.md` in the version folder?
- Did the feedback.md include: prompt quality score, skill gaps detected, token efficiency, user feedback received, AI self-assessment?
- Did you save the feedback report to Engram (`feedback/version-report/{version}`)?

---

## Section 7: Self-Assessment

Answer these final questions honestly:

1. On a scale of 0-100, how compliant was this session with the autoSDD v4 framework?
2. What was the #1 reason you deviated from the framework?
3. Was the framework itself unclear, too complex, or impractical in any specific way?
4. If you could redo this session, what would you do differently?
5. What specific changes to the SKILL.md or CLAUDE.md would make it easier for you to follow the framework?

---

## Output Format

Structure your response as:

```
## Section 1: Pipeline Execution
### 1.1 Prompt Analyst: [DONE/PARTIALLY/NOT DONE]
Evidence: [quote or explain]
...

## Section 2: CREA Framework Compliance
...
```

Do NOT summarize or skip sections. Answer EVERY question. This audit is mandatory.
