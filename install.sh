#!/usr/bin/env bash
set -euo pipefail

# autoSDD Installer — installs gentle-ai + autoSDD skill
# Works on macOS and Linux. For Windows, use install.ps1

REPO_URL="https://raw.githubusercontent.com/thestark77/autosdd/main"
SKILL_URL="$REPO_URL/skill/SKILL.md"

AGENTS=(
  "claude-code"
  "opencode"
  "kilocode"
  "gemini-cli"
  "cursor"
  "vscode-copilot"
  "codex"
  "antigravity"
  "windsurf"
  "kimi"
  "qwen-code"
  "kiro-ide"
)

AGENT_DIRS=(
  "$HOME/.claude"
  "$HOME/.config/opencode"
  "$HOME/.config/kilo"
  "$HOME/.gemini"
  "$HOME/.cursor"
  "$HOME/.copilot"
  "$HOME/.codex"
  "$HOME/.gemini/antigravity"
  "$HOME/.codeium/windsurf"
  "$HOME/.kimi"
  "$HOME/.qwen"
  "$HOME/.kiro"
)

PERSONAS=("gentleman" "neutral" "custom")

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║     autoSDD v3 — Installer               ║"
echo "  ║     Self-Improving Autonomous Dev         ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""

# --- Step 1: Agent Selection ---
echo "Step 1/2 — Select AI agents to configure"
echo "  (ENTER = all agents)"
echo ""
for i in "${!AGENTS[@]}"; do
  printf "  %2d. %s\n" $((i + 1)) "${AGENTS[$i]}"
done
echo ""
read -rp "  Agents (comma-separated numbers, e.g. 1,3,5): " agent_input

selected_agents=""
if [[ -z "$agent_input" ]]; then
  selected_agents=$(IFS=,; echo "${AGENTS[*]}")
  echo "  → All agents selected"
else
  IFS=',' read -ra nums <<< "$agent_input"
  agent_list=()
  for n in "${nums[@]}"; do
    n=$(echo "$n" | tr -d ' ')
    idx=$((n - 1))
    if [[ $idx -ge 0 && $idx -lt ${#AGENTS[@]} ]]; then
      agent_list+=("${AGENTS[$idx]}")
    fi
  done
  selected_agents=$(IFS=,; echo "${agent_list[*]}")
  echo "  → Selected: $selected_agents"
fi
echo ""

# --- Step 2: Persona Selection ---
echo "Step 2/2 — Select AI response style"
echo "  (ENTER = neutral)"
echo ""
echo "  1. gentleman  — Rioplatense Spanish, passionate, opinionated"
echo "  2. neutral     — Professional, no regional style"
echo "  3. custom      — Define your own"
echo ""
read -rp "  Persona (1/2/3): " persona_input

selected_persona="neutral"
case "$persona_input" in
  1) selected_persona="gentleman" ;;
  2) selected_persona="neutral" ;;
  3) selected_persona="custom" ;;
  *) selected_persona="neutral" ;;
esac
echo "  → Selected: $selected_persona"
echo ""

# --- Check gentle-ai ---
echo "Checking prerequisites..."

if ! command -v gentle-ai &>/dev/null; then
  echo ""
  echo "  ⚠ gentle-ai not found. Install it first:"
  echo ""
  echo "    macOS/Linux:  brew install gentle-ai"
  echo "    Go:           go install github.com/gentleman-programming/gentle-ai/cmd/gentle-ai@latest"
  echo "    Manual:       https://github.com/Gentleman-Programming/gentle-ai#installation"
  echo ""
  exit 1
fi
echo "  ✓ gentle-ai $(gentle-ai version 2>/dev/null || echo 'found')"

if ! command -v curl &>/dev/null; then
  echo "  ✗ curl not found. Please install curl."
  exit 1
fi
echo "  ✓ curl"
echo ""

# --- Install gentle-ai ---
echo "Installing gentle-ai..."
echo "  Agents:   $selected_agents"
echo "  Persona:  $selected_persona"
echo "  Preset:   full-gentleman"
echo "  SDD Mode: multi"
echo ""

gentle-ai install \
  --agents "$selected_agents" \
  --persona "$selected_persona" \
  --preset full-gentleman \
  --sdd-mode multi

echo ""
echo "  ✓ gentle-ai installed"

# --- Configure OpenCode profiles (if opencode was selected) ---
if echo "$selected_agents" | grep -q "opencode"; then
  echo ""
  echo "Configuring OpenCode SDD profiles..."
  gentle-ai sync \
    --agents opencode \
    --profile autosdd:openrouter/anthropic/claude-opus-4-6 \
    --profile-phase autosdd:sdd-init:openrouter/anthropic/claude-sonnet-4-6 \
    --profile-phase autosdd:sdd-explore:openrouter/anthropic/claude-sonnet-4-6 \
    --profile-phase autosdd:sdd-propose:openrouter/google/gemini-2.5-pro-preview \
    --profile-phase autosdd:sdd-spec:openrouter/google/gemini-2.5-pro-preview \
    --profile-phase autosdd:sdd-design:openrouter/anthropic/claude-opus-4-6 \
    --profile-phase autosdd:sdd-tasks:openrouter/openai/gpt-5.4 \
    --profile-phase autosdd:sdd-apply:openrouter/anthropic/claude-sonnet-4-6 \
    --profile-phase autosdd:sdd-verify:openrouter/openai/gpt-5.4 \
    --profile-phase autosdd:sdd-archive:openrouter/anthropic/claude-sonnet-4-6 \
    2>/dev/null || echo "  ⚠ OpenCode profile config skipped (OpenCode may not be installed)"
  echo "  ✓ OpenCode profiles configured"
fi

# --- Install autoSDD SKILL.md ---
echo ""
echo "Installing autoSDD skill..."

for i in "${!AGENTS[@]}"; do
  agent="${AGENTS[$i]}"
  if echo "$selected_agents" | grep -q "$agent"; then
    skill_dir="${AGENT_DIRS[$i]}/skills/autosdd"
    mkdir -p "$skill_dir"
    curl -fsSL -o "$skill_dir/SKILL.md" "$SKILL_URL"
    echo "  ✓ $agent → $skill_dir/SKILL.md"
  fi
done

# --- Install RTK (Rust Token Killer) ---
echo ""
echo "Installing RTK (token optimization)..."

if command -v rtk &>/dev/null; then
  echo "  ✓ RTK already installed ($(rtk --version 2>/dev/null || echo 'found'))"
else
  curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
  if command -v rtk &>/dev/null; then
    echo "  ✓ RTK installed"
  else
    echo "  ⚠ RTK install script ran but 'rtk' not in PATH. You may need to restart your shell."
    echo "    Manual: https://github.com/rtk-ai/rtk"
  fi
fi

# --- Verify prompt-engineering-patterns ---
echo ""
echo "Verifying prompt-engineering-patterns skill..."

pep_found=false
for i in "${!AGENTS[@]}"; do
  agent="${AGENTS[$i]}"
  if echo "$selected_agents" | grep -q "$agent"; then
    pep_dir="${AGENT_DIRS[$i]}/skills/prompt-engineering-patterns"
    if [[ -f "$pep_dir/SKILL.md" ]]; then
      pep_found=true
      break
    fi
  fi
done

if $pep_found; then
  echo "  ✓ prompt-engineering-patterns found (installed by gentle-ai)"
else
  echo "  ⚠ prompt-engineering-patterns not found."
  echo "    This skill is CORE to autoSDD (used with CREA on ALL prompts)."
  echo "    It should be installed by gentle-ai --preset full-gentleman."
  echo "    Run: gentle-ai sync --skills prompt-engineering-patterns"
fi

# --- Bootstrap project templates ---
echo ""
echo "Bootstrapping project templates..."

TEMPLATE_URL="$REPO_URL/templates"
CONTEXT_DIR="./context"

if [[ -d "$CONTEXT_DIR" ]]; then
  echo "  context/ directory already exists — skipping existing files"
fi

mkdir -p "$CONTEXT_DIR"

templates=("guidelines.md" "user_context.md" "business_logic.md" "autosdd.md")
for tmpl in "${templates[@]}"; do
  target="$CONTEXT_DIR/$tmpl"
  if [[ -f "$target" ]]; then
    echo "  · $tmpl already exists — skipped"
  else
    curl -fsSL -o "$target" "$TEMPLATE_URL/$tmpl"
    echo "  ✓ $tmpl → $target"
  fi
done

# --- Inject autoSDD block into CLAUDE.md ---
AUTOSDD_BLOCK='<!-- autosdd:start -->
## autoSDD — Active Framework (DO NOT REMOVE)

autoSDD v3 is the ACTIVE development framework for this project.
ALL prompts go through autoSDD unless the user explicitly opts out.

### Default Behavior
- Every prompt → Flow Router → CREA Prompt Refine → Execute Flow → Outcome Collection
- CREA framework (Context, Role, Specificity, Action) + prompt-engineering-patterns on ALL prompt creation
- 5 flows: Development, Code Review, Debugging, Research, Self-Improvement
- Orchestrator delegates to sub-agents, NEVER executes directly
- Monitor tool for ALL waiting/watching (NEVER poll)
- RTK prefix on ALL shell commands

### Three Critical Context Files (sacred, auto-updated)
- `context/guidelines.md` — Technical rules and conventions
- `context/user_context.md` — User profile and preferences
- `context/business_logic.md` — Domain knowledge and workflows

### Opt-Out
- `[raw]` prefix: skip framework entirely
- `[no-sdd]` prefix: skip SDD but keep CREA
- `skip autosdd`: natural language opt-out

Read the autoSDD skill: `~/.claude/skills/autosdd/SKILL.md`
<!-- autosdd:end -->'

if [[ ! -f "./CLAUDE.md" ]]; then
  curl -fsSL -o "./CLAUDE.md" "$TEMPLATE_URL/CLAUDE.md"
  echo "  ✓ CLAUDE.md → ./CLAUDE.md (full template)"
elif grep -q "autosdd:start" "./CLAUDE.md"; then
  # Replace existing block between markers
  sed -i '/<!-- autosdd:start -->/,/<!-- autosdd:end -->/d' "./CLAUDE.md"
  printf '%s\n' "$AUTOSDD_BLOCK" >> "./CLAUDE.md"
  echo "  ✓ CLAUDE.md → autoSDD block updated (markers replaced)"
else
  # Append block to existing CLAUDE.md
  printf '\n%s\n' "$AUTOSDD_BLOCK" >> "./CLAUDE.md"
  echo "  ✓ CLAUDE.md → autoSDD block injected (appended)"
fi

# --- Done ---
echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║     autoSDD v3 installed!                ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""
echo "  What was installed:"
echo "    ✓ gentle-ai (SDD skills, Engram memory, agent config)"
echo "    ✓ autoSDD skill (methodology layer)"
echo "    ✓ RTK (token optimization — 60-90% savings)"
echo "    ✓ Project templates (context/ + CLAUDE.md)"
echo ""
echo "  Next steps:"
echo "    1. Open your project in your AI agent"
echo "    2. Run /sdd-init to bootstrap the project"
echo "    3. Run /sdd-new <feature> to start building"
echo ""
echo "  Update autoSDD later:"
echo "    curl -fsSL $REPO_URL/install.sh | bash"
echo ""
echo "  Docs: https://github.com/thestark77/autosdd"
echo ""
