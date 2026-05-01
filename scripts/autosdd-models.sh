#!/usr/bin/env bash
# autosdd-models — Manage model presets for autoSDD
# Usage: autosdd-models <command> [args]
#
# Commands:
#   list              List available presets
#   show [preset]     Show active preset (or specified preset) and its models
#   set <preset>      Switch active preset (updates models.json + opencode.json)
#   apply             Generate/update opencode.json agents from active preset
#   add <name>        Create a new preset by copying the active one (then edit)

set -uo pipefail

MODELS_FILE=""
PROJECT_ROOT=""

find_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/context/models.json" ]]; then
      PROJECT_ROOT="$dir"
      MODELS_FILE="$dir/context/models.json"
      return 0
    fi
    if [[ -f "$dir/CLAUDE.md" ]] || [[ -d "$dir/context" ]]; then
      PROJECT_ROOT="$dir"
      MODELS_FILE="$dir/context/models.json"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  echo "ERROR: Cannot find project root (no context/models.json found)." >&2
  echo "Run this command from inside an autoSDD project, or run 'autosdd-models init' first." >&2
  exit 1
}

# Resolve model ID for a given role from the active preset
resolve_model() {
  local role="$1"
  local active
  active=$(jq -r '.active' "$MODELS_FILE")
  jq -r ".presets.\"$active\".models.\"$role\"" "$MODELS_FILE" 2>/dev/null
}

cmd_list() {
  local active
  active=$(jq -r '.active' "$MODELS_FILE")
  echo ""
  echo "  autoSDD Model Presets"
  echo "  ======================"
  echo ""
  jq -r '.presets | keys[]' "$MODELS_FILE" | while read -r preset; do
    local desc
    desc=$(jq -r ".presets.\"$preset\".description" "$MODELS_FILE")
    local marker=" "
    if [[ "$preset" == "$active" ]]; then
      marker="*"
    fi
    printf "  %s %-12s %s\n" "$marker" "$preset" "$desc"
  done
  echo ""
  echo "  Active: $active"
  echo ""
}

cmd_show() {
  local preset="${1:-}"
  if [[ -z "$preset" ]]; then
    preset=$(jq -r '.active' "$MODELS_FILE")
  fi

  local desc
  desc=$(jq -r ".presets.\"$preset\".description // empty" "$MODELS_FILE" 2>/dev/null)
  if [[ -z "$desc" ]]; then
    echo "ERROR: Preset '$preset' not found in $MODELS_FILE" >&2
    echo "Available presets:" >&2
    jq -r '.presets | keys[]' "$MODELS_FILE" >&2
    exit 1
  fi

  local provider
  provider=$(jq -r ".presets.\"$preset\".provider" "$MODELS_FILE")

  echo ""
  echo "  Preset: $preset"
  echo "  Description: $desc"
  echo "  Provider: $provider"
  echo ""
  echo "  Role                    Model"
  echo "  ----------------------- -------------------------------------------"
  jq -r ".presets.\"$preset\".models | to_entries[] | .key + \" \" + .value" "$MODELS_FILE" | \
    while IFS=' ' read -r role model; do
      printf "  %-23s %s\n" "$role" "$model"
    done
  echo ""
}

cmd_set() {
  local preset="$1"

  if [[ -z "$preset" ]]; then
    echo "ERROR: Specify a preset name." >&2
    echo "Usage: autosdd-models set <preset>" >&2
    cmd_list
    exit 1
  fi

  local exists
  exists=$(jq -r ".presets.\"$preset\" | type" "$MODELS_FILE" 2>/dev/null)
  if [[ "$exists" == "null" ]]; then
    echo "ERROR: Preset '$preset' not found." >&2
    echo "Available presets:" >&2
    jq -r '.presets | keys[]' "$MODELS_FILE" >&2
    exit 1
  fi

  local tmp
  tmp=$(jq ".active = \"$preset\"" "$MODELS_FILE")
  echo "$tmp" > "$MODELS_FILE"

  echo ""
  echo "  Switched to preset: $preset"
  echo ""

  cmd_show "$preset"

  echo "  Run 'autosdd-models apply' to update opencode.json"
  echo ""
}

cmd_apply() {
  local active
  active=$(jq -r '.active' "$MODELS_FILE")

  local default_model
  default_model=$(resolve_model "default")

  local opencode_file="$PROJECT_ROOT/opencode.json"

  if [[ ! -f "$opencode_file" ]]; then
    echo "{}" > "$opencode_file"
  fi

  local agent_block="{}"
  local roles
  roles=$(jq -r ".presets.\"$active\".models | keys[]" "$MODELS_FILE")

  while IFS= read -r role; do
    local model
    model=$(resolve_model "$role")

    # Skip 'default' and 'orchestrator' from agents (default goes to root model, orchestrator is root)
    if [[ "$role" == "default" ]]; then
      continue
    fi

    local desc
    case "$role" in
      orchestrator)    desc="autoSDD orchestrator — coordinates, delegates, never writes code" ;;
      context-scout)   desc="autoSDD context scout — gathers and filters project context" ;;
      sdd-init)        desc="autoSDD SDD init — project initialization and stack detection" ;;
      sdd-explore)     desc="autoSDD SDD explore — codebase exploration and analysis" ;;
      sdd-propose)     desc="autoSDD SDD propose — architectural proposal generation" ;;
      sdd-spec)        desc="autoSDD SDD spec — specification writing" ;;
      sdd-design)      desc="autoSDD SDD design — system and interface design" ;;
      sdd-tasks)       desc="autoSDD SDD tasks — task breakdown and planning" ;;
      sdd-apply)       desc="autoSDD SDD apply — implementation and code generation" ;;
      sdd-verify)      desc="autoSDD SDD verify — validation and testing" ;;
      sdd-archive)     desc="autoSDD SDD archive — version close and documentation" ;;
      prompt-analyst)  desc="autoSDD prompt analyst — fast inline prompt analysis" ;;
      feedback-report)  desc="autoSDD feedback report — structured report generation" ;;
      knowledge-graph) desc="autoSDD knowledge graph — memory visualization" ;;
      version-close)   desc="autoSDD version close — template-based artifact generation" ;;
      knowledge-update) desc="autoSDD knowledge update — context and memory updates" ;;
      precompact-save)  desc="autoSDD precompact save — state serialization before compaction" ;;
      *)               desc="autoSDD $role" ;;
    esac

    local agent_entry
    agent_entry=$(jq -n \
      --arg desc "$desc" \
      --arg model "$model" \
      '{description: $desc, model: $model}')
    agent_block=$(echo "$agent_block" | jq --arg role "$role" --argjson entry "$agent_entry" ". + {($role): $entry}")
  done

  # Also set orchestrator model in root
  local orch_model
  orch_model=$(resolve_model "orchestrator")

  # Build final opencode.json content
  local new_config
  new_config=$(jq --arg model "$default_model" \
    --argjson agents "$agent_block" \
    --arg orch_model "$orch_model" \
    '. + {
      "model": $model,
      "agent": (.agent // {} | . + {
        "autosdd-orchestrator": {
          "description": "autoSDD orchestrator — coordinates, delegates, never writes code",
          "model": $orch_model,
          "prompt": "You are the autoSDD orchestrator. You DELEGATE all work to sub-agents. You coordinate the pipeline: VERSION INIT -> CONTEXT SCOUT -> TRIAGE -> ROUTE -> PLAN -> DELEGATE -> COLLECT -> CLOSE -> KNOWLEDGE UPDATE. You NEVER write source code directly. You read context/models.json to determine which model to assign to each role."
        }
      })
    }' "$opencode_file")

  echo "$new_config" | jq '.' > "$opencode_file"

  echo ""
  echo "  Applied preset '$active' to $opencode_file"
  echo "  Root model: $default_model"
  echo "  Orchestrator: $orch_model"
  echo "  Agents configured: $(echo "$agent_block" | jq 'length') roles"
  echo ""
}

cmd_add() {
  local name="$1"

  if [[ -z "$name" ]]; then
    echo "ERROR: Specify a preset name." >&2
    echo "Usage: autosdd-models add <name>" >&2
    exit 1
  fi

  local exists
  exists=$(jq -r ".presets.\"$name\" | type" "$MODELS_FILE" 2>/dev/null)
  if [[ "$exists" != "null" ]]; then
    echo "ERROR: Preset '$name' already exists." >&2
    exit 1
  fi

  local active
  active=$(jq -r '.active' "$MODELS_FILE")

  local tmp
  tmp=$(jq --arg name "$name" --arg active "$active" \
    '.presets[$name] = .presets[$active]' "$MODELS_FILE")
  echo "$tmp" > "$MODELS_FILE"

  echo ""
  echo "  Created preset '$name' (copied from '$active')"
  echo "  Edit context/models.json to customize model assignments."
  echo ""
}

cmd_init() {
  local target_dir="${1:-$PWD}"

  if [[ ! -f "$target_dir/context/models.json" ]]; then
    mkdir -p "$target_dir/context"

    # Find the script's directory to get the template
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local template="$script_dir/../templates/models.json"

    if [[ -f "$template" ]]; then
      cp "$template" "$target_dir/context/models.json"
      echo "  Created $target_dir/context/models.json from template"
    else
      # Fallback: copy from this script's repo context/
      local repo_template="$script_dir/../context/models.json"
      if [[ -f "$repo_template" ]]; then
        cp "$repo_template" "$target_dir/context/models.json"
        echo "  Created $target_dir/context/models.json from repo"
      else
        echo "ERROR: Cannot find models.json template." >&2
        exit 1
      fi
    fi
  else
    echo "  context/models.json already exists — skipping"
  fi

  MODELS_FILE="$target_dir/context/models.json"
  PROJECT_ROOT="$target_dir"
  echo ""
  cmd_show
}

case "${1:-}" in
  list)
    find_project_root
    cmd_list
    ;;
  show)
    find_project_root
    cmd_show "${2:-}"
    ;;
  set)
    find_project_root
    cmd_set "${2:-}"
    ;;
  apply)
    find_project_root
    cmd_apply
    ;;
  add)
    find_project_root
    cmd_add "${2:-}"
    ;;
  init)
    cmd_init "${2:-$PWD}"
    ;;
  *)
    echo "autoSDD Model Presets — Manage model assignments for different providers"
    echo ""
    echo "Usage: autosdd-models <command> [args]"
    echo ""
    echo "Commands:"
    echo "  init              Initialize context/models.json in the current project"
    echo "  list              List available presets"
    echo "  show [preset]     Show active (or specified) preset details"
    echo "  set <preset>      Switch to a different preset"
    echo "  apply             Generate/update opencode.json from active preset"
    echo "  add <name>        Create a new preset (copies the active one)"
    echo ""
    echo "Preset presets: quality (Zen), balanced (mixed), economy (Go)"
    echo "Configuration: context/models.json"
    ;;
esac