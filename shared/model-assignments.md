# Model Assignments

Read this table at session start (or before first delegation), cache it for the session, and pass the mapped alias in every Agent tool call via the `model` parameter. If a phase is missing, use the `default` row. If you lack access to the assigned model, substitute `sonnet` and continue.

| Phase | Default Model | Reason |
|-------|---------------|--------|
| orchestrator | opus | Coordinates, makes decisions |
| sdd-explore | sonnet | Reads code, structural - not architectural |
| sdd-propose | opus | Architectural decisions |
| sdd-spec | sonnet | Structured writing |
| sdd-design | opus | Architecture decisions |
| sdd-tasks | sonnet | Mechanical breakdown |
| sdd-apply | sonnet | Implementation |
| sdd-verify | sonnet | Validation against spec |
| sdd-archive | sonnet | Copy and close |
| prompt-analyst | haiku | Fast inline analysis, no architecture decisions |
| feedback-report | sonnet | Structured writing from data |
| knowledge-graph | sonnet | Data extraction and graph building |
| default | sonnet | Non-SDD general delegation |
