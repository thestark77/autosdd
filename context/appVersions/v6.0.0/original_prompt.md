---
conversation_id: v6.0.0-cost-optimization
date: 2026-04-30
---

# Original Prompt — autoSDD v6.0

## Problem Statement
Context information is growing massively across projects (business logic, user context, guidelines, style guides, brand references, code across 10+ repos, Engram semantic memory). This floods the orchestrator with 0-20% relevant context per prompt. Semantic search returns many vectorially close but task-irrelevant results.

## Proposed Solution
1. **Context Scout** — A cheap Haiku sub-agent that runs before the orchestrator, gathers context from all sources, filters for relevance, and passes only what's needed.
2. **Cost optimization** — Delegate mechanical tasks (version close, knowledge update, memory management, pre-compact saves) to Haiku instead of Opus.
3. **Automation via scripts** — Replace AI-driven mechanical tasks (folder creation, PROGRESS reset, version lint) with bash/PowerShell scripts.
4. **Event-driven enforcement** — Monitor Tool for all waits, never sleep/poll. Non-negotiable.
5. **Memory Manager** — Concise saves, dedup checks, max 5 lines per observation.
6. **be-code-kit sync** — Update IT-Bemovil/be-code-kit to reflect v6.0 changes.

## Key Constraints
- SKILL.md must stay under 300 lines
- Installers must handle v5.3 → v6.0 update automatically
- gentle-ai's model-assignments.md must NOT be modified (autoSDD extends inline)
- No hook loops (SubagentStop must exclude utility agents)
- be-code-kit has real users on v5.3 right now
