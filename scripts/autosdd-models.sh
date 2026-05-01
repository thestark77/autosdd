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

  local opencode_file="$PROJECT_ROOT/opencode.json"

  if [[ ! -f "$opencode_file" ]]; then
    echo '{}' > "$opencode_file"
  fi

  local build_model
  build_model=$(resolve_model "orchestrator")
  local compaction_model
  compaction_model=$(resolve_model "precompact-save")
  local explore_model
  explore_model=$(resolve_model "context-scout")
  local general_model
  general_model=$(resolve_model "default")
  local title_model
  title_model=$(resolve_model "version-close")

  if [[ -z "$build_model" || "$build_model" == "null" ]]; then
    build_model=$(resolve_model "default")
  fi
  if [[ -z "$compaction_model" || "$compaction_model" == "null" ]]; then
    compaction_model=$build_model
  fi
  if [[ -z "$explore_model" || "$explore_model" == "null" ]]; then
    explore_model=$build_model
  fi
  if [[ -z "$general_model" || "$general_model" == "null" ]]; then
    general_model=$build_model
  fi
  if [[ -z "$title_model" || "$title_model" == "null" ]]; then
    title_model=$build_model
  fi

  local new_config
  new_config=$(jq \
    --arg schema "https://opencode.ai/config.json" \
    --arg build "$build_model" \
    --arg compaction "$compaction_model" \
    --arg explore "$explore_model" \
    --arg general "$general_model" \
    --arg title "$title_model" \
    '{
      "$schema": $schema,
      "agent": {
        "build": { "model": $build },
        "compaction": { "model": $compaction },
        "explore": { "model": $explore },
        "general": { "model": $general },
        "title": { "model": $title }
      },
      "instructions": ["opencode.md"]
    }' "$opencode_file")

  echo "$new_config" | jq '.' > "$opencode_file"

  local username
  username=$(whoami 2>/dev/null || echo "user")
  if jq -e '.username' "$opencode_file" > /dev/null 2>&1; then
    true
  else
    local tmp
    tmp=$(jq --arg u "$username" '. + {username: $u}' "$opencode_file")
    echo "$tmp" | jq '.' > "$opencode_file"
  fi

  echo ""
  echo "  Applied preset '$active' to $opencode_file"
  echo "  OpenCode agents:"
  echo "    build (orchestrator):  $build_model"
  echo "    compaction:           $compaction_model"
  echo "    explore (context):     $explore_model"
  echo "    general (default):     $general_model"
  echo "    title:                $title_model"
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