# Changelog

All notable changes to **autoSDD** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

autoSDD is an orchestration framework for Claude Code that enforces a structured delegation pipeline (Triage → Route → Plan → Delegate → Collect → Close → Knowledge Update) on top of the gentle-ai foundation.

---

## [Unreleased]

### Added
- Session Observation Protocol (Section 6): orchestrator MUST save compliance notes to Engram at each pipeline step with topic key `telemetry/obs/{project}/{session-marker}/{step}`. Observations capture what actually happened, deviations, metrics snapshot, and friction points. They survive compaction and sessions.
- Observation Lifecycle: each observation has a `Status` field (`pending` → `applied`). `/improve` marks consumed observations as applied — never deletes them. Full audit trail of framework evolution.
- `LEARNING.md` consolidated changelog: framework-level record of what autoSDD has learned from real-world usage. Updated by `/improve` after user approval. INDEX format — content lives in Engram, LEARNING.md is a pointer table.
- autosdd-telemetry v2.1.0: complete rewrite with Session Observation Protocol, Consolidated Learning Protocol (tiered knowledge: observations → learnings → rules), Feedback Compliance Audit, Engram-driven `/improve`, observation lifecycle management, and `LEARNING.md` maintenance protocol.
- Tiered Knowledge Architecture: raw observations (Engram, per-step per-session) → consolidated learnings by category (Engram, retrieved per pipeline step) → promoted rules (SKILL.md, permanent). Data reduction target: 70 observations → 5-15 learnings. Category-based retrieval at ~50 tokens/learning.
- Consolidated Learning Protocol: 7 categories (delegation, frontend, backend, testing, architecture, anti-patterns, user-preferences). Topic keys: `learnings/{project}/{category}/{id}` and `learnings/general/{category}/{id}`. Consolidation rules: 2+ observations = learning, 1 HIGH = immediate, 1 LOW = wait. Promotion to SKILL.md after 3+ sessions HIGH severity.
- Learning Retrieval Strategy: TRIAGE searches anti-patterns, PLAN searches task-specific categories, DELEGATE injects into Standards, COLLECT validates against anti-patterns. Never loads all learnings at once.
- Pipeline Gates: MANDATORY checkpoints visible in CLAUDE.md template. G1 (before planning): learnings + pending searched. G2 (before delegating): CREA prompt.md + skills. G3 (before collecting): observations saved + feedback asked. G4 (before closing): feedback.md + Engram summary.
- Claude Code Hooks for structural enforcement: SubagentStop (checkpoint reminder), PreCompact (mandatory Engram save), Stop (close checklist). Configured in `.claude/settings.json`. Agent sees reminders automatically — doesn't need to remember.
- Feedback Compliance Audit in autosdd-telemetry: automated checks for feedback.md existence per version, feedback.md quality (telemetry section + discoveries table), and proactive questions count. Common failure causes documented (segmented versions, compaction, pipeline skip).
- Compaction Protocol (Step 8): proactive context window management. Suggests /compact at milestones when context > 50%. Mandatory at 70%+. Persists Engram summary and resumption plan before compacting.
- Reference Solicitation: orchestrator proactively asks for references at triage. Non-blocking — saved to TODO if deferred. References flow through CREA context and sub-agent launch template.
- Self-Analysis Protocol (`/self-analysis`): in-session self-audit against v5.0 checkpoints with feedback gap detection (NON-COMPLIANT markers for missing feedback.md or zero questions asked), learning retrieval compliance (E3 section), and per-version feedback.md table.

### Changed
- `/improve` flow: now includes Consolidation Step — groups pending observations by THEME, creates/updates consolidated learnings (not just audit reports). Searches Engram observations as PRIMARY input, aggregates qualitative + quantitative data. Marks consumed observations as `applied` and appends index entry to `LEARNING.md`.
- Feedback enforcement: Steps 5 (COLLECT) and 6 (CLOSE) now use MANDATORY language. "Ask user feedback (MANDATORY)" in Step 5, "If feedback.md not generated, session is NON-COMPLIANT" in Step 6. Section 9 Active feedback changed from "Active" to "Active (MANDATORY)" with explicit rules.
- New telemetry metrics: `feedback_questions_asked`, `feedback_md_generated`, `learning_retrievals` added to /audit metric extraction.
- Learning retrieval at TRIAGE: `mem_search("learnings/{project}")` added to Step 1 to surface anti-patterns and relevant learnings BEFORE planning.
- gentle-ai relationship: changed from hard prerequisite to optional enhancement. autoSDD degrades gracefully if gentle-ai is missing or outdated.
- Dependency Gate: changed from WARN+STOP to WARN+CONTINUE (degraded mode).
- Engram Memory Protocol (Section 6): added Consolidated Learnings paragraph with category taxonomy and retrieval-by-category rule. Session observations and learnings are two complementary layers.
- `templates/CLAUDE.md`: added Pipeline Gates table, Hooks section, tiered knowledge description, and MANDATORY feedback language.

---

## [5.0.0] - 2026-04-26

### Added
- Telemetry system with `/audit` and `/improve` commands via new `autosdd-telemetry` skill.
- Active feedback collection: non-blocking questions posed to the user at UI, feature, refactor, design, and architecture decision moments.
- TODO list review enforced at the Triage, Collect, and Close pipeline phases.
- Monitoring rule: orchestrator MUST use the Monitor tool for event-driven waiting; `sleep`/polling loops are prohibited.
- `gentle-ai` prerequisite gate — autoSDD will not initialise unless `gentle-ai` is detected in the environment.
- Dependency gate: missing Engram, Context7, `prompt-engineering-patterns`, or RTK triggers WARN and STOP rather than silent degradation.

### Changed
- `SKILL.md` line count: ~825 lines (v4.0) → ~250 lines (v4.1) → 277 lines (v5.0).
- Pipeline expanded from 5 steps to 7 steps: TRIAGE added as step 1, KNOWLEDGE UPDATE added as step 7.
- CREA now applied **once** on `prompt.md` only; was applied three times in v4.0 (user prompt, `prompt.md`, and each sub-agent prompt individually).
- Sub-agent prompts are now **derived** from `prompt.md` via mechanical extraction rather than a fresh CREA application per sub-agent.
- Skill routing simplified to a pattern-match lookup table; previously a 6-step Engram-based resolution protocol.
- Version close now appends a telemetry metrics section to `feedback.md`.
- Installers refactored: removed gentle-ai-owned duplicates (`branch-pr`, `judgment-day`, four shared protocol files) and added the new `autosdd-telemetry` skill.
- `CLAUDE.md` template simplified: the autoSDD block is now a pointer to `SKILL.md` rather than an inline duplicate of its content.

### Removed
- Triple CREA application — replaced by a single application on `prompt.md`.
- 6-step skill resolution protocol — replaced by the pattern-match table.
- Duplicate skills that gentle-ai already provides: `branch-pr` and `judgment-day` moved to gentle-ai ownership.
- Shared protocol installation for files gentle-ai already manages (`persona`, `sdd-orchestrator`, `engram-protocol`, `model-assignments`).

---

## [4.1.0] - 2026-04-26

### Added
- Orchestrator-first identity declared as Section 1 of `SKILL.md`: "You DO NOT write code. You DELEGATE."
- Fill-in-the-blank sub-agent launch template (Section 4) to standardise delegation calls.
- Anti-inline rule with high salience to prevent orchestrators from writing source code directly.
- Sub-agent failure recovery protocol: DIAGNOSE → IMPROVE → RE-DELEGATE (never write the code yourself).
- Prompt engineering technique selection per task type: Few-Shot, Chain-of-Thought, Structured Output, Self-Consistency.

### Changed
- `SKILL.md` rewritten from ~825 lines to ~250 lines.
- CREA reduced from triple application to a single application on `prompt.md`.
- Skill routing simplified from the 6-step resolution protocol to a lookup table.
- Section structure reorganised so that proximity to the top correlates with salience (critical rules appear first).

### Fixed
- ProHuella audit returned a compliance score of 8/100; the following root causes were addressed:
  - `SKILL.md` was too long (825 lines → ~250 lines).
  - No enforcement mechanism existed for the no-inline-code rule (anti-inline rules and a pre-delegation checklist added).
  - Triple CREA application was unrealistic in practice (reduced to single application).
  - Skill resolution required too many steps (simplified to lookup table).
  - Orchestrators defaulted to writing code inline when sub-agents failed (explicit recovery protocol added).

---

## [4.0.0] - 2026-04-15

### Added
- Initial autoSDD framework with 5-flow routing: DEV, DEBUG, REVIEW, RESEARCH, IMPROVE.
- CREA Framework (Context, Role, Specificity, Action) for structured prompt construction.
- Prompt Analyst with quality scoring to evaluate prompt clarity before delegation.
- Bidirectional feedback system: AI-to-User education loop and User-to-AI preference learning.
- Self-improvement engine with A/B testing across prompt variants.
- 3 Sacred Context Files: `guidelines`, `user_context`, `business_logic`.
- Knowledge Graph visualisation for surfacing relationships between project artefacts.
- 14 core skills auto-installed on first run.
- One-command installers for both bash (`install.sh`) and PowerShell (`install.ps1`).
- Built on the gentle-ai foundation.

---

[Unreleased]: https://github.com/user/autosdd/compare/v5.0.0...HEAD
[5.0.0]: https://github.com/user/autosdd/compare/v4.1.0...v5.0.0
[4.1.0]: https://github.com/user/autosdd/compare/v4.0.0...v4.1.0
[4.0.0]: https://github.com/user/autosdd/releases/tag/v4.0.0
