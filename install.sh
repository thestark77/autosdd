#!/usr/bin/env bash
# autoSDD Installer — installs gentle-ai + autoSDD skill
# Works on macOS and Linux. For Windows, use install.ps1

# Wrap in function so exit doesn't kill the user's shell when run via curl | bash
_autosdd_install() {

set -uo pipefail

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

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║     autoSDD v3 — Installer               ║"
echo "  ║     Self-Improving Autonomous Dev        ║"
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

# --- Check prerequisites ---
echo "Checking prerequisites..."

# Check Homebrew
if ! command -v brew &>/dev/null; then
  echo ""
  echo "  ⚠ Homebrew is required to install dependencies on macOS/Linux."
  echo ""
  echo "  Install Homebrew first:"
  echo "    https://brew.sh"
  echo ""
  echo "  Then run this installer again."
  echo ""
  return 1
fi
echo "  ✓ brew"

# Check curl
if ! command -v curl &>/dev/null; then
  echo "  ✗ curl not found. Please install curl."
  return 1
fi
echo "  ✓ curl"

# Check Node.js (required by Context7 MCP and npx commands)
if ! command -v node &>/dev/null; then
  echo "  · Node.js not found — installing via brew..."
  if ! brew install node; then
    echo "  ✗ Node.js installation failed."
    echo "  Install manually: https://nodejs.org/en/download"
    return 1
  fi
fi
echo "  ✓ node $(node --version 2>/dev/null)"

# Check Go (required by engram, installed by gentle-ai)
if ! command -v go &>/dev/null; then
  echo "  · Go not found — installing via brew..."
  if ! brew install go; then
    echo "  ✗ Go installation failed."
    echo "  Install manually: https://go.dev/dl/"
    return 1
  fi
fi
echo "  ✓ go"

# Ensure GOBIN is in PATH (engram binary lands here)
gobin=$(go env GOBIN 2>/dev/null)
if [[ -z "$gobin" ]]; then
  gobin="$(go env GOPATH 2>/dev/null)/bin"
fi
if [[ -n "$gobin" && ":$PATH:" != *":$gobin:"* ]]; then
  export PATH="$PATH:$gobin"
  # Persist for future shells
  shell_rc=""
  if [[ -f "$HOME/.zshrc" ]]; then
    shell_rc="$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    shell_rc="$HOME/.bashrc"
  fi
  if [[ -n "$shell_rc" ]] && ! grep -q "$gobin" "$shell_rc" 2>/dev/null; then
    echo "export PATH=\"\$PATH:$gobin\"" >> "$shell_rc"
    echo "  ✓ added $gobin to PATH ($shell_rc)"
  fi
fi

# Check gentle-ai
if ! command -v gentle-ai &>/dev/null; then
  echo "  · gentle-ai not found — installing via brew..."
  brew tap Gentleman-Programming/homebrew-tap 2>/dev/null
  if ! brew install gentle-ai; then
    echo ""
    echo "  ✗ gentle-ai installation failed."
    echo "  Try manually: brew install gentle-ai"
    echo "  Docs: https://github.com/Gentleman-Programming/gentle-ai#installation"
    echo ""
    return 1
  fi
fi
echo "  ✓ gentle-ai $(gentle-ai version 2>/dev/null || echo 'found')"
echo ""

# --- Stop running engram process (prevents file lock issues during update) ---
if pgrep -x "engram" &>/dev/null; then
  echo "  · Stopping running engram process (required to update binary)..."
  pkill -x "engram" 2>/dev/null
  sleep 1
  echo "  ✓ engram process stopped"
fi

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
  --sdd-mode multi || {
  echo ""
  echo "  ⚠ gentle-ai exited with warnings (verification issues)."
  echo "  This usually means installation completed with non-critical issues."
  echo "  Continuing with the rest of the setup..."
}

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

installed_skill_paths=()
for i in "${!AGENTS[@]}"; do
  agent="${AGENTS[$i]}"
  if echo "$selected_agents" | grep -q "$agent"; then
    skill_dir="${AGENT_DIRS[$i]}/skills/autosdd"
    mkdir -p "$skill_dir"
    if curl -fsSL -o "$skill_dir/SKILL.md" "$SKILL_URL"; then
      installed_skill_paths+=("$skill_dir/SKILL.md")
      echo "  ✓ $agent → $skill_dir/SKILL.md"
    else
      echo "  ⚠ Failed to download SKILL.md for $agent"
    fi
  fi
done

# --- Install RTK (Rust Token Killer) ---
echo ""
echo "Installing RTK (token optimization)..."

if command -v rtk &>/dev/null; then
  echo "  ✓ RTK already installed ($(rtk --version 2>/dev/null || echo 'found'))"
else
  if curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh; then
    if command -v rtk &>/dev/null; then
      echo "  ✓ RTK installed"
    else
      echo "  ⚠ RTK install script ran but 'rtk' not in PATH. You may need to restart your shell."
      echo "    Manual: https://github.com/rtk-ai/rtk"
    fi
  else
    echo "  ⚠ RTK auto-install failed. Install manually:"
    echo "    cargo install rtk"
    echo "    OR download from: https://github.com/rtk-ai/rtk/releases"
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
    if curl -fsSL -o "$target" "$TEMPLATE_URL/$tmpl"; then
      echo "  ✓ $tmpl → $target"
    else
      echo "  ⚠ Failed to download $tmpl"
    fi
  fi
done

# --- Inject autoSDD block into CLAUDE.md ---

# Build skill path references for all selected agents
skill_refs=""
for p in "${installed_skill_paths[@]}"; do
  skill_refs="${skill_refs}
- \`$p\`"
done

AUTOSDD_BLOCK="<!-- autosdd:start -->
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
- \`context/guidelines.md\` — Technical rules and conventions
- \`context/user_context.md\` — User profile and preferences
- \`context/business_logic.md\` — Domain knowledge and workflows

### Opt-Out
- \`[raw]\` prefix: skip framework entirely
- \`[no-sdd]\` prefix: skip SDD but keep CREA
- \`skip autosdd\`: natural language opt-out

Read the full framework: \`context/autosdd.md\`
autoSDD skill installed at:${skill_refs}
<!-- autosdd:end -->"

if [[ ! -f "./CLAUDE.md" ]]; then
  if curl -fsSL -o "./CLAUDE.md" "$TEMPLATE_URL/CLAUDE.md"; then
    echo "  ✓ CLAUDE.md → ./CLAUDE.md (full template)"
  else
    echo "  ⚠ Failed to download CLAUDE.md template"
  fi
fi

# Inject or update autoSDD block (even in freshly downloaded template)
if [[ -f "./CLAUDE.md" ]]; then
  if grep -q "autosdd:start" "./CLAUDE.md"; then
    sed -i '/<!-- autosdd:start -->/,/<!-- autosdd:end -->/d' "./CLAUDE.md"
    printf '%s\n' "$AUTOSDD_BLOCK" >> "./CLAUDE.md"
    echo "  ✓ CLAUDE.md → autoSDD block updated (markers replaced)"
  else
    printf '\n%s\n' "$AUTOSDD_BLOCK" >> "./CLAUDE.md"
    echo "  ✓ CLAUDE.md → autoSDD block injected (appended)"
  fi
fi

# --- Final Verification ---
echo ""
echo "Verifying installation..."
echo ""

all_good=true

# Check gentle-ai
if command -v gentle-ai &>/dev/null; then
  echo "  [OK] gentle-ai"
else
  echo "  [!!] gentle-ai NOT found"
  all_good=false
fi

# Check engram
if command -v engram &>/dev/null; then
  echo "  [OK] engram MCP"
else
  echo "  [..] engram NOT in PATH — restart your terminal"
fi

# Check RTK
if command -v rtk &>/dev/null; then
  echo "  [OK] RTK"
else
  echo "  [..] RTK not in PATH — restart terminal or install: cargo install rtk"
fi

# Check autoSDD skill for each selected agent
for p in "${installed_skill_paths[@]}"; do
  if [[ -f "$p" ]]; then
    echo "  [OK] $p"
  else
    echo "  [!!] MISSING: $p"
    all_good=false
  fi
done

# Check SDD skills (from gentle-ai)
sdd_skills=("sdd-init" "sdd-explore" "sdd-propose" "sdd-spec" "sdd-design" "sdd-tasks" "sdd-apply" "sdd-verify" "sdd-archive")
for i in "${!AGENTS[@]}"; do
  agent="${AGENTS[$i]}"
  if echo "$selected_agents" | grep -q "$agent"; then
    missing_skills=()
    for skill in "${sdd_skills[@]}"; do
      if [[ ! -f "${AGENT_DIRS[$i]}/skills/$skill/SKILL.md" ]]; then
        missing_skills+=("$skill")
      fi
    done
    if [[ ${#missing_skills[@]} -eq 0 ]]; then
      echo "  [OK] SDD skills ($agent) — all 9 installed"
    else
      echo "  [!!] SDD skills ($agent) — MISSING: ${missing_skills[*]}"
      all_good=false
    fi

    # Check prompt-engineering-patterns
    if [[ -f "${AGENT_DIRS[$i]}/skills/prompt-engineering-patterns/SKILL.md" ]]; then
      echo "  [OK] prompt-engineering-patterns ($agent)"
    else
      echo "  [!!] prompt-engineering-patterns MISSING ($agent)"
      all_good=false
    fi
    break
  fi
done

# Check project templates
if [[ -f "./context/autosdd.md" ]]; then
  echo "  [OK] Project templates (context/)"
else
  echo "  [!!] Project templates missing"
  all_good=false
fi

# Check CLAUDE.md injection
if [[ -f "./CLAUDE.md" ]] && grep -q "autosdd:start" "./CLAUDE.md"; then
  echo "  [OK] CLAUDE.md autoSDD block"
else
  echo "  [!!] CLAUDE.md autoSDD block missing"
  all_good=false
fi

# --- Done ---
echo ""
if $all_good; then
  echo "  ╔══════════════════════════════════════════╗"
  echo "  ║     autoSDD v3 installed!                ║"
  echo "  ╚══════════════════════════════════════════╝"
else
  echo "  ╔══════════════════════════════════════════╗"
  echo "  ║  autoSDD v3 installed (with warnings)    ║"
  echo "  ╚══════════════════════════════════════════╝"
  echo ""
  echo "  Some checks failed. Re-run the installer or fix manually."
fi
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

}

_autosdd_install
unset -f _autosdd_install
