# autoSDD v5.1 — Session Analysis & Improvement Plan
> Session: e135e27e-1196-451e-a039-f69274acb167 · Project: Bemovil2.0 · Date: 2026-04-27
> Compliance Score: **18/100** (CRITICAL FAILURE)

---

## 1. General Assessment

### Evidence Summary

| Indicator | Expected | Actual | Verdict |
|-----------|----------|--------|---------|
| `original_prompt.md` per version | 3 (v0.1–v0.3) | 0 | NOT DONE |
| `prompt.md` per version | 3 | 1 (v0.3.0 only, retroactive) | PARTIAL |
| `feedback.md` per version | 3 | 1 (v0.1.0 only, retroactive) | PARTIAL |
| PROGRESS.md (ongoing) | Updated continuously | Created retroactively after user correction | PARTIAL |
| Tasks delegated (v0.1.0) | All | 0 (14 inline edits) | NOT DONE |
| Engram saves (proactive) | ≥1 per pipeline step | 0 reported | NOT DONE |
| Feedback questions asked | ≥1 per feature | 0 | NOT DONE |
| Session observations | ≥1 per step | 0 | NOT DONE |
| Compaction survival | Full context persisted pre-compact | Prompts lost, context degraded | NOT DONE |
| Skill injection in sub-agents | TEXT rules in ## Standards | Unknown (prompts lost to compaction) | LIKELY NOT DONE |

### Root Cause Analysis

The session failure is NOT a single point — it's a **cascade of structural enforcement gaps**:

1. **Versioning not enforced structurally**: SKILL.md says "create version folder" but there is NO hook or gate that BLOCKS execution until the folder exists. It's just text in a long document.

2. **PreCompact hook is toothless**: The hook fires a `type: "prompt"` that says "save stuff before compacting." But the agent can (and did) ignore it because:
   - It's a reminder, not a BLOCKER
   - There's no validation that the save actually happened
   - The compaction proceeds regardless of whether the agent complied

3. **Delegation rule has no enforcement**: SKILL.md Section 1 says "delegate" but there's no mechanism that PREVENTS the orchestrator from calling Write/Edit on source files. The SubagentStop hook fires AFTER delegation — it can't prevent inline work.

4. **Context loss spiral**: Without `original_prompt.md` saved at the start, every compaction erases the original intent. Without `PROGRESS.md` updated continuously, there's no recovery anchor. The agent loses its plan and starts improvising.

5. **Feedback is "MANDATORY" in text only**: Nothing structurally prevents the agent from closing a version without `feedback.md`. The Stop hook checks but doesn't block.

### User's Assessment: 70/100 on results, but process was chaotic

The agent produced decent frontend results but at enormous cost: $100 plan consumed, multiple context compactions with data loss, tasks forgotten or ignored post-compaction, no feedback loop, no learning captured.

---

## 2. Current-State Flowchart — autoSDD v5.1 (AS-IS)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    USER SENDS PROMPT                                  │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  HOOK: UserPromptSubmit                                              │
│  Action: rm -f .claude/.stop-hook-fired (reset debounce)             │
│  Type: command (always fires)                                        │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 1 — TRIAGE (inline, 15s)                                       │
│                                                                      │
│  Decisions:                                                          │
│  ├─ mem_search("pending/{project}") ← SHOULD check pending tasks    │
│  ├─ mem_search("learnings/{project}") ← SHOULD check anti-patterns  │
│  ├─ Evaluate prompt clarity: HIGH/MEDIUM/LOW                         │
│  ├─ Detect feedback? → persist to Engram + context files             │
│  └─ Ask for references? (non-blocking)                               │
│                                                                      │
│  Saves: Engram observation (telemetry/obs/{project}/{date}/triage)   │
│  Files: NOTHING yet                                                  │
│  Gate G1: learnings searched + pending searched                       │
│                                                                      │
│  ⚠ PROBLEM: No structural enforcement. Agent CAN skip all of this.  │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 2 — ROUTE (inline)                                             │
│                                                                      │
│  Decision: DEV / DEBUG / REVIEW / RESEARCH                           │
│  Saves: Engram observation                                           │
│  Files: NOTHING                                                      │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 3 — PLAN (inline)                                              │
│                                                                      │
│  Actions:                                                            │
│  ├─ Create version folder: context/appVersions/vX.Y.Z/              │
│  ├─ Save original_prompt.md (user's raw prompt)                      │
│  ├─ Build prompt.md with CREA structure                              │
│  └─ Apply prompt-engineering-patterns                                │
│                                                                      │
│  Saves: Engram observation                                           │
│  Files: original_prompt.md, prompt.md (in version folder)            │
│  Gate G2: CREA prompt exists + skills resolved + model set           │
│                                                                      │
│  ⚠ PROBLEM: "Create version folder" is just text. No hook checks.   │
│  ⚠ PROBLEM: original_prompt.md not mentioned explicitly in SKILL.md │
│    (only in Section 10 as "Version folder" brief mention)            │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 4 — DELEGATE (via Agent tool)                                  │
│                                                                      │
│  For EACH task in prompt.md:                                         │
│  ├─ Fill Sub-Agent Launch Template (6 sections)                      │
│  │   ├─ ## Context                                                   │
│  │   ├─ ## Role                                                      │
│  │   ├─ ## Standards (auto-resolved) ← skill rules as TEXT           │
│  │   ├─ ## Task                                                      │
│  │   ├─ ## Validation                                                │
│  │   └─ ## Return Contract                                           │
│  ├─ Set `model` parameter (sonnet/opus)                              │
│  └─ Call Agent tool                                                   │
│                                                                      │
│  Pre-launch gate: verify all 6 sections filled                       │
│                                                                      │
│  ⚠ PROBLEM: Pre-launch gate is an inline checkpoint (mental note),  │
│    NOT a structural blocker. Agent can skip it.                       │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                    ┌────────┴────────┐
                    ▼                 ▼
         ┌──── Sub-Agent 1 ────┐  ┌──── Sub-Agent N ────┐
         │  Executes task      │  │  Executes task      │
         │  Returns results    │  │  Returns results    │
         └─────────┬───────────┘  └─────────┬───────────┘
                   │                         │
                   └────────────┬────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  HOOK: SubagentStop (fires after EACH sub-agent returns)             │
│  Type: prompt                                                        │
│  Message: "Run Step 5 checkpoint (observation saved? feedback debt?)" │
│                                                                      │
│  ⚠ PROBLEM: This is just a reminder injected into context.          │
│    The agent receives it but can ignore it entirely.                  │
│    No validation that the checkpoint was actually executed.           │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 5 — COLLECT (inline)                                           │
│                                                                      │
│  Actions:                                                            │
│  ├─ Validate sub-agent results                                       │
│  ├─ Re-delegate if failed (DIAGNOSE → IMPROVE → RE-DELEGATE)        │
│  ├─ Save Engram observation                                          │
│  └─ Ask user ≥1 feedback question (MANDATORY)                        │
│                                                                      │
│  Gate G3: observation saved + ≥1 feedback question asked             │
│                                                                      │
│  ⚠ PROBLEM: "MANDATORY" is only text. Nothing blocks Step 6         │
│    from executing without the feedback question.                      │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 6 — CLOSE VERSION (inline)                                     │
│                                                                      │
│  Actions:                                                            │
│  ├─ Generate feedback.md in version folder (with telemetry)          │
│  ├─ Update PROGRESS.md                                               │
│  ├─ Save Engram summary (feedback/version-report/{version})          │
│  └─ Remind user of pending questions/tasks                           │
│                                                                      │
│  Gate G4: feedback.md exists + Engram saved                          │
│                                                                      │
│  ⚠ PROBLEM: Same as above — "NON-COMPLIANT" label has no teeth.    │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 7 — KNOWLEDGE UPDATE (inline)                                  │
│                                                                      │
│  Actions:                                                            │
│  ├─ Update guidelines.md / user_context.md / business_logic.md       │
│  ├─ Save discoveries to Engram                                       │
│  └─ Doc sync check (README + CHANGELOG if framework changed)         │
│                                                                      │
│  Saves: Engram discoveries, context files                            │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 8 — COMPACTION CHECK                                           │
│                                                                      │
│  Decision tree:                                                      │
│  ├─ Context < 50%  → Continue (no action)                            │
│  ├─ Context 50-70% → Suggest /compact at next milestone              │
│  └─ Context > 70%  → MANDATORY compaction                            │
│                                                                      │
│  Before suggesting:                                                  │
│  ├─ Save Engram session summary                                      │
│  ├─ Persist all pending state                                        │
│  └─ Create resumption plan                                           │
│                                                                      │
│  ⚠ PROBLEM: With CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=60, the system     │
│    auto-compacts WITHOUT asking. The agent NEVER gets to "suggest."  │
│    The PreCompact hook fires but it's just a reminder.               │
│    Result: context vanishes without the agent having saved anything. │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                    ┌────────┴──────────────────┐
                    │                           │
                    ▼                           ▼
        [No compaction needed]      [AUTO-COMPACTION TRIGGERED]
        Continue to next prompt              │
                                             ▼
                              ┌─────────────────────────────────────┐
                              │  HOOK: PreCompact                    │
                              │  Type: prompt                        │
                              │  Message: "Save to Engram + plan     │
                              │   state BEFORE proceeding"           │
                              │                                      │
                              │  ⚠ Agent receives this but has NO   │
                              │    time guarantee. Compaction may    │
                              │    proceed immediately after.        │
                              │  ⚠ No PostCompact hook to verify    │
                              │    recovery succeeded.               │
                              └──────────────┬──────────────────────┘
                                             │
                                             ▼
                              ┌─────────────────────────────────────┐
                              │  [COMPACTION HAPPENS]                │
                              │  Previous messages summarized.       │
                              │  Prompts, decisions, context LOST.   │
                              │                                      │
                              │  ⚠ No PostCompact hook exists.      │
                              │  ⚠ Agent continues with degraded    │
                              │    context. May forget tasks,        │
                              │    skip versioning, lose prompts.    │
                              └─────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  HOOK: Stop (fires when agent stops responding)                      │
│  Type: command (with debounce via .stop-hook-fired marker)           │
│  Message: "feedback.md generated? README+CHANGELOG reflect changes?  │
│   Unsaved observations?"                                             │
│                                                                      │
│  ⚠ PROBLEM: Non-blocking. Agent already stopped. The output goes    │
│    to stdout but doesn't trigger agent action in all cases.          │
└─────────────────────────────────────────────────────────────────────┘
```

### How gentle-ai Connects

```
┌─────────────────────────────────────────────────────────────────────┐
│                        gentle-ai (Foundation)                         │
│                                                                      │
│  Provides:                                                           │
│  ├─ Engram MCP (memory persistence across sessions)                  │
│  ├─ SDD Orchestrator protocol (delegation patterns)                  │
│  ├─ 10 SDD phase skills (init/explore/propose/spec/design/          │
│  │   tasks/apply/verify/archive/onboard)                             │
│  ├─ Skill resolver (loads SKILL.md files)                            │
│  ├─ Context7 MCP (documentation search)                              │
│  ├─ Persona (language, tone, operating rules)                        │
│  └─ Model assignments (sonnet/opus per phase)                        │
│                                                                      │
│  Connection point: autoSDD's Section 6 (Engram Protocol) wraps       │
│  gentle-ai's Engram MCP with specific topic key conventions.         │
│  autoSDD's Section 4 (Sub-Agent Template) extends gentle-ai's        │
│  SDD Orchestrator with CREA structure and skill injection.           │
│                                                                      │
│  Relationship: OPTIONAL enhancement. autoSDD degrades gracefully.    │
└─────────────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────────┐
│ Engram MCP   │    │ SDD Phases   │    │ Shared Protocols │
│              │    │              │    │                  │
│ mem_save     │    │ sdd-init     │    │ persona.md       │
│ mem_search   │    │ sdd-explore  │    │ engram-proto.md  │
│ mem_context  │    │ sdd-propose  │    │ sdd-orch.md      │
│ mem_update   │    │ sdd-spec     │    │ model-assign.md  │
│ mem_session  │    │ sdd-design   │    │ rtk.md (autoSDD) │
│  _summary    │    │ sdd-tasks    │    │                  │
│              │    │ sdd-apply    │    │                  │
│              │    │ sdd-verify   │    │                  │
│              │    │ sdd-archive  │    │                  │
└──────────────┘    └──────────────┘    └──────────────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     autoSDD v5.1 (Methodology Layer)                 │
│                                                                      │
│  ADDS on top of gentle-ai:                                           │
│  ├─ Meta-pipeline (8 steps with gates)                               │
│  ├─ CREA prompt structure                                            │
│  ├─ Telemetry (/audit, /improve, /self-analysis)                     │
│  ├─ Bidirectional feedback (passive + active)                        │
│  ├─ RTK token optimization                                           │
│  ├─ Version folder protocol (appVersions/)                           │
│  ├─ Compaction check (Step 8)                                        │
│  ├─ Claude Code hooks (SubagentStop, PreCompact, Stop, Submit)       │
│  └─ Additional skills (frontend-design, interface-design, etc.)      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Improvement Analysis (/improve)

### Problem Taxonomy

| # | Problem | Root Cause | Severity | Frequency |
|---|---------|-----------|----------|-----------|
| P1 | Orchestrator writes code inline | Section 1 is TEXT-ONLY, no structural blocker | CRITICAL | Every session |
| P2 | Version folder not created at start | Not enforced by hook or gate with blocking semantics | CRITICAL | This session |
| P3 | Context lost on compaction | PreCompact hook is a non-blocking reminder; no PostCompact recovery; auto-compact fires before agent can save | CRITICAL | Every compaction |
| P4 | No feedback questions asked | "MANDATORY" label without enforcement | HIGH | This session |
| P5 | No feedback.md generated (most versions) | Same — text-only enforcement | HIGH | This session |
| P6 | PROGRESS.md not maintained continuously | Not tied to any trigger or hook | HIGH | This session |
| P7 | original_prompt.md never created | Barely mentioned in SKILL.md (Section 10, one line) | HIGH | This session |
| P8 | Engram observations = 0 | Too many "save at each step" instructions buried in long text | MEDIUM | This session |
| P9 | Sub-agent prompts lost to compaction | Not saved to file before launching | MEDIUM | After compaction |
| P10 | Skills not provably injected | No audit trail of what was injected into each sub-agent | LOW | Unknown |

### Root Cause Summary

**The fundamental failure mode is: autoSDD v5.1 relies on the agent READING and OBEYING a 298-line document. When context is compressed, or when the agent is in "flow state" executing tasks, it ignores the methodology because nothing STRUCTURALLY prevents it from doing so.**

The hooks that exist (SubagentStop, PreCompact, Stop) are all "reminders" — type: "prompt" or stdout messages. They inject text but don't block execution. The agent treats them as suggestions.

### Design Principles for v5.2

1. **If it's mandatory, it must be enforced structurally** — not by text, not by "MANDATORY" labels, not by prompt reminders.
2. **Compaction survival must be file-based** — Engram is great for cross-session, but WITHIN a session, the agent needs FILES it can re-read after compaction (PROGRESS.md, prompt.md, etc.).
3. **The first action on ANY prompt must be versioning** — before thinking, before planning, before anything.
4. **Hooks must DO things, not just remind** — if PreCompact needs a save, the hook should PERFORM the save (or at minimum create a checkpoint file the agent can recover from).
5. **PostCompact recovery must be automatic** — the agent must know WHERE to look and WHAT to re-read after context compression.

---

## 4. New Flowchart — autoSDD v5.2 (TO-BE)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    USER SENDS PROMPT                                  │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  HOOK: UserPromptSubmit                                              │
│  Type: command                                                       │
│  Actions:                                                            │
│  ├─ Reset stop-hook marker: rm -f .claude/.stop-hook-fired           │
│  └─ Capture raw prompt to .claude/.last-prompt.md (backup)           │
│                                                                      │
│  NEW: Raw prompt capture ensures original_prompt.md source exists    │
│  even if the agent forgets to save it.                               │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 0 — VERSION INIT (FIRST ACTION, NON-NEGOTIABLE)                │
│  ═══════════════════════════════════════════════════════════════════  │
│                                                                      │
│  BEFORE any thinking or planning:                                    │
│  1. Determine version number (read PROGRESS.md → next version)       │
│  2. Create folder: context/appVersions/vX.Y.Z/                      │
│  3. Save original_prompt.md (raw user input, verbatim)               │
│  4. Create PROGRESS.md entry: "vX.Y.Z — STARTED — {timestamp}"      │
│                                                                      │
│  ENFORCEMENT: SKILL.md Section 0 states this is the LITERAL FIRST   │
│  thing. The PreCompact hook CHECKS for version folder existence.     │
│  If missing at any point, the agent is NON-COMPLIANT.                │
│                                                                      │
│  Files created: original_prompt.md, PROGRESS.md updated              │
│  Gate G0: Version folder exists with original_prompt.md              │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 1 — TRIAGE (inline, 15s)                                       │
│                                                                      │
│  Actions (same as v5.1):                                             │
│  ├─ mem_search("pending/{project}")                                  │
│  ├─ mem_search("learnings/{project}")                                │
│  ├─ Evaluate clarity: HIGH/MEDIUM/LOW                                │
│  ├─ Detect feedback → persist                                        │
│  └─ Ask for references (non-blocking)                                │
│                                                                      │
│  Gate G1: learnings + pending searched                                │
│  Observation: saved to Engram                                        │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 2 — ROUTE                                                      │
│  Decision: DEV / DEBUG / REVIEW / RESEARCH                           │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 3 — PLAN (CREA)                                                │
│                                                                      │
│  Actions:                                                            │
│  ├─ Build prompt.md with CREA structure                              │
│  ├─ Save to version folder: context/appVersions/vX.Y.Z/prompt.md    │
│  ├─ Update PROGRESS.md: "vX.Y.Z — PLANNED — {task count} tasks"     │
│  └─ Apply prompt-engineering-patterns                                │
│                                                                      │
│  Gate G2: prompt.md exists in version folder                         │
│  Files: prompt.md saved (survives compaction as a FILE)              │
│                                                                      │
│  NEW: PROGRESS.md gets task list summary here. This is the           │
│  compaction-survival anchor.                                         │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 4 — DELEGATE                                                   │
│                                                                      │
│  For EACH task:                                                      │
│  ├─ Fill 6-section template (Context/Role/Standards/Task/Val/Return) │
│  ├─ Set `model` parameter                                            │
│  ├─ Inject skill rules as TEXT                                       │
│  ├─ NEW: Save sub-agent prompt summary to PROGRESS.md               │
│  │   (1-2 lines per delegation: task name + files + status)          │
│  └─ Call Agent tool                                                   │
│                                                                      │
│  Pre-launch gate: all 6 sections + model + skills verified           │
│                                                                      │
│  NEW: PROGRESS.md now contains a LOG of what was delegated.          │
│  This survives compaction and allows recovery.                        │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                    ┌────────┴────────┐
                    ▼                 ▼
         ┌──── Sub-Agent 1 ────┐  ┌──── Sub-Agent N ────┐
         └─────────┬───────────┘  └─────────┬───────────┘
                   └────────────┬────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  HOOK: SubagentStop                                                  │
│  Type: prompt                                                        │
│  Message: "Sub-agent returned. Update PROGRESS.md with result        │
│   (DONE/FAILED/PARTIAL + 1-line note). Then: observation to Engram.  │
│   Feedback debt: have you asked ≥1 question this version?"           │
│                                                                      │
│  CHANGE: Now explicitly requires PROGRESS.md update (file-based,     │
│  survives compaction). Previously only mentioned Engram.              │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 5 — COLLECT                                                    │
│                                                                      │
│  Actions:                                                            │
│  ├─ Validate results (delegate validation if complex)                │
│  ├─ Update PROGRESS.md: task status (DONE/FAILED/PARTIAL)            │
│  ├─ Re-delegate if failed                                            │
│  ├─ Save Engram observation                                          │
│  └─ Ask user ≥1 feedback question (MANDATORY)                        │
│                                                                      │
│  Gate G3: PROGRESS.md updated + observation saved + feedback asked   │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 6 — CLOSE VERSION                                              │
│                                                                      │
│  Actions:                                                            │
│  ├─ Generate feedback.md in version folder                           │
│  ├─ Update PROGRESS.md: "vX.Y.Z — CLOSED — {date}"                  │
│  ├─ Save Engram summary                                              │
│  └─ Surface pending items to user                                    │
│                                                                      │
│  Gate G4: feedback.md exists + PROGRESS.md says CLOSED               │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 7 — KNOWLEDGE UPDATE                                           │
│  (same as v5.1)                                                      │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 8 — COMPACTION CHECK                                           │
│  (same as v5.1, but now the FILES exist to survive it)               │
└─────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════
                    COMPACTION HANDLING (NEW IN v5.2)
═══════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────┐
│  HOOK: PreCompact (ENHANCED)                                         │
│  Type: prompt                                                        │
│  Message (NEW — more directive):                                     │
│  "COMPACTION IMMINENT. You WILL lose conversation context.           │
│   Execute NOW (not later):                                           │
│   1. Update PROGRESS.md with current state of ALL in-flight tasks    │
│   2. Save to Engram: mem_save with topic 'session/{project}/{date}'  │
│      containing: current task, decisions made, next steps            │
│   3. If feedback.md not yet generated for current version: note in   │
│      PROGRESS.md 'feedback.md PENDING — generate after compaction'   │
│   4. List files agent should re-read after compaction in PROGRESS.md │
│                                                                      │
│   After compaction you MUST: re-read PROGRESS.md + current version   │
│   prompt.md + guidelines.md. These are your recovery anchors."       │
│                                                                      │
│  KEY DIFFERENCE from v5.1: The message now gives SPECIFIC actions    │
│  with SPECIFIC files, not a vague "save stuff."                      │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  [COMPACTION HAPPENS — context compressed]                            │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│  POST-COMPACTION RECOVERY (structural — in SKILL.md Section 0)       │
│                                                                      │
│  The COMPACTED agent sees in its system prompt (CLAUDE.md):          │
│  "After ANY compaction, your FIRST actions are:                      │
│   1. Read PROGRESS.md (your recovery anchor)                         │
│   2. Read current version's prompt.md                                │
│   3. mem_context() + mem_search('session/{project}')                 │
│   4. Resume from where PROGRESS.md says you left off"                │
│                                                                      │
│  This works because CLAUDE.md is ALWAYS in context (system prompt).  │
│  Even after compaction, the agent has these instructions.             │
│                                                                      │
│  Recovery files (always exist if pipeline was followed):             │
│  ├─ PROGRESS.md (global, with per-version task status)               │
│  ├─ context/appVersions/vX.Y.Z/prompt.md (the plan)                 │
│  ├─ context/appVersions/vX.Y.Z/original_prompt.md (user intent)     │
│  └─ Engram: session/{project}/{date} (decisions, context)            │
└─────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════
                    STOP / SESSION END
═══════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────┐
│  HOOK: Stop (ENHANCED — debounced)                                   │
│  Type: command (fires once per user interaction)                      │
│                                                                      │
│  Checks:                                                             │
│  ├─ feedback.md exists for current version?                          │
│  ├─ PROGRESS.md up to date?                                          │
│  └─ Unsaved observations?                                            │
│                                                                      │
│  Output: reminder to agent (non-blocking, same as v5.1)              │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Differences v5.1 → v5.2

| Aspect | v5.1 | v5.2 |
|--------|------|------|
| Version folder creation | Mentioned in Step 3 text | **Step 0** — FIRST action, before anything |
| original_prompt.md | Barely mentioned (Section 10) | **Mandatory in Step 0** + backup via UserPromptSubmit hook |
| PROGRESS.md role | Updated at close only | **Living document** — updated at every step transition |
| Compaction survival | Relies on Engram only | **File-based**: PROGRESS.md + prompt.md + Engram (triple redundancy) |
| PreCompact hook | Vague "save stuff" | **Specific 4-action checklist** with named files |
| PostCompact recovery | "mem_context → re-read Sections 1-4" | **Explicit file reading sequence** in CLAUDE.md (always visible) |
| SubagentStop hook | "observation saved? feedback debt?" | **"Update PROGRESS.md"** (file-based, concrete) |
| Sub-agent prompts | Only in conversation (lost on compaction) | **Summary logged in PROGRESS.md** |
| Delegation enforcement | Text in Section 1 | **Section 0 declares versioning FIRST** — if agent writes code before versioning, it's provably non-compliant |
| Feedback enforcement | "MANDATORY" text label | **Gate G3 explicitly checks** + Stop hook reminds |

---

## 5. Structural Guarantees (What Makes v5.2 Different)

The core insight: **You cannot enforce behavior on an LLM with text alone. You need FILE-BASED anchors that survive context loss and HOOKS that provide consistent reminders.**

### Triple Redundancy Model

```
┌─────────────────────────────────────────────────────────────────────┐
│  LAYER 1: CLAUDE.md (System Prompt — ALWAYS visible)                 │
│  Contains: Post-compaction recovery instructions                     │
│  Survives: Everything (always loaded)                                │
├─────────────────────────────────────────────────────────────────────┤
│  LAYER 2: File-based state (PROGRESS.md + version folder)            │
│  Contains: Current state, task status, what to do next               │
│  Survives: Compaction, session changes                               │
├─────────────────────────────────────────────────────────────────────┤
│  LAYER 3: Engram (cross-session memory)                              │
│  Contains: Decisions, discoveries, learnings                         │
│  Survives: Everything (external persistence)                         │
└─────────────────────────────────────────────────────────────────────┘
```

When compaction happens:
- Layer 1 tells the agent WHAT to do (re-read instructions in CLAUDE.md)
- Layer 2 tells the agent WHERE it was (PROGRESS.md + prompt.md)
- Layer 3 tells the agent WHY decisions were made (Engram)

All three layers independently survive compaction. v5.1 relied primarily on Layer 3 (Engram), which requires the agent to REMEMBER to call `mem_context` — something it often fails to do after a disorienting compaction.

---

*Analysis completed: 2026-04-27 · autoSDD dogfooding session*
*Next: implement v5.2.0 changes to SKILL.md, templates, installers, and hooks*
