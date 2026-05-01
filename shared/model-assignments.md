# Model Assignments

Read `context/models.json` at session start (or before first delegation) to resolve the active preset. The `active` field selects which preset to use. Pass the mapped model ID in every Agent tool call via the `model` parameter.

## OpenCode Agents

For OpenCode, run `autosdd-models apply` to generate `opencode.json` with agent definitions that map each autoSDD role to its model from the active preset.

## Presets

Three built-in presets are provided:

| Preset | Provider | Description |
|--------|----------|-------------|
| `quality` | opencode (Zen) | Max quality — all paid models via OpenCode Zen |
| `balanced` | mixed | Zen for critical decisions (orchestrator, verify), Go for everything else |
| `economy` | opencode-go (Go) | Min cost — all Go plan models ($10/mo) |

Switch presets: `autosdd-models set <preset>` then `autosdd-models apply`.

Add custom presets: Edit `context/models.json` → add entry under `presets`, then `autosdd-models apply`.

## Fallback alias table

For agents that do not support `context/models.json` (e.g., Claude Code without OpenCode), use these aliases:

| Phase | Default Model | Reason |
|-------|---------------|--------|
| orchestrator | opus | Coordinates, makes decisions |
| sdd-init | sonnet | Stack detection, structured output |
| sdd-explore | sonnet | Reads code, structural - not architectural |
| sdd-propose | opus | Architectural decisions |
| sdd-spec | sonnet | Structured writing |
| sdd-design | opus | Architecture decisions |
| sdd-tasks | sonnet | Mechanical breakdown |
| sdd-apply | sonnet | Implementation |
| sdd-verify | sonnet | Validation against spec |
| sdd-archive | sonnet | Copy and close |
| context-scout | haiku | Gather + filter, no reasoning needed |
| version-close | haiku | Template-based artifact generation |
| knowledge-update | haiku | Mechanical updates + memory saves |
| precompact-save | haiku | State serialization under time pressure |
| prompt-analyst | haiku | Fast inline analysis, no architecture decisions |
| feedback-report | sonnet | Structured writing from data |
| knowledge-graph | sonnet | Data extraction and graph building |
| default | sonnet | Non-SDD general delegation |

If a phase is missing, use the `default` row. If you lack access to the assigned model, substitute `sonnet` and continue.

## Model ID format

- **OpenCode Zen**: `opencode/<model-id>` (e.g., `opencode/claude-opus-4-6`)
- **OpenCode Go**: `opencode-go/<model-id>` (e.g., `opencode-go/kimi-k2.6`)
- **Claude Code**: `anthropic/<model-id>` (e.g., `anthropic/claude-opus-4-6`)