#!/usr/bin/env bash
# autoSDD Installer - installs gentle-ai + autoSDD skill
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

# Auto-detect: update mode if autoSDD skill already exists for any agent
UPDATE_MODE=false
for dir in "${AGENT_DIRS[@]}"; do
  if [[ -f "$dir/skills/autosdd/SKILL.md" ]]; then
    UPDATE_MODE=true
    break
  fi
done

# Warning collector - populated throughout the install for the final report.
warnings=()

# --- Embedding backend configuration ---
# Curated list of OpenAI-compatible embedding providers.
# Models chosen for quality/cost balance (≤$0.10/1M tokens) with multilingual support.
# Index 0 = local (Ollama); indexes 1-5 = remote API providers.
EMBED_PROVIDER_NAMES=(
  "local"
  "OpenAI"
  "OpenRouter"
  "Voyage AI"
  "Mistral"
  "Jina AI"
)
EMBED_PROVIDER_URLS=(
  ""   # local Ollama is hardcoded in wrapper (http://localhost:11434/v1/embeddings)
  "https://api.openai.com/v1/embeddings"
  "https://openrouter.ai/api/v1/embeddings"
  "https://api.voyageai.com/v1/embeddings"
  "https://api.mistral.ai/v1/embeddings"
  "https://api.jina.ai/v1/embeddings"
)
EMBED_PROVIDER_MODELS=(
  "bge-m3"                              # local Ollama - best open multilingual
  "text-embedding-3-small"              # OpenAI - $0.02/1M, 1536 dims
  "openai/text-embedding-3-small"       # OpenRouter - same model proxied
  "voyage-3"                            # Voyage - $0.06/1M, strong multilingual
  "mistral-embed"                       # Mistral - $0.10/1M, 1024 dims
  "jina-embeddings-v3"                  # Jina - $0.02/1M, top multilingual MTEB
)

# Ollama local defaults
OLLAMA_LOCAL_URL="http://localhost:11434/v1/embeddings"
OLLAMA_LOCAL_MODEL="bge-m3"

# State directory for dual-mode (local + api) configuration
ENGRAM_STATE_DIR="$HOME/.engram"
KEYCHAIN_SERVICE="engram-embedding"

# --- Helper: validate an API key by issuing a real embed request ---
# Usage: validate_api_key <url> <model> <key>  → exit 0 on HTTP 200, non-zero otherwise
validate_api_key() {
  local url="$1" model="$2" key="$3"
  local http_code
  http_code=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 15 \
    -X POST "$url" \
    -H "Authorization: Bearer $key" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$model\",\"input\":[\"hello\"]}" 2>/dev/null || echo "000")
  [[ "$http_code" == "200" ]]
}

# --- Helper: store API key in OS keychain, fall back to chmod 600 file ---
# Never echoes the key. Returns "keychain" or "file" to indicate storage used.
store_api_key_secure() {
  local key="$1"
  if command -v security &>/dev/null; then
    # macOS Keychain - -U updates if exists
    if security add-generic-password -U -a "$USER" -s "$KEYCHAIN_SERVICE" -w "$key" 2>/dev/null; then
      echo "macOS Keychain"; return
    fi
  fi
  if command -v secret-tool &>/dev/null; then
    # libsecret (GNOME Keyring / KWallet)
    if printf '%s' "$key" | secret-tool store --label="Engram Embedding API key" \
         service "$KEYCHAIN_SERVICE" account "$USER" 2>/dev/null; then
      echo "libsecret"; return
    fi
  fi
  # Fallback: chmod 600 file under ENGRAM_STATE_DIR
  mkdir -p "$ENGRAM_STATE_DIR" && chmod 700 "$ENGRAM_STATE_DIR"
  local old_umask; old_umask=$(umask); umask 077
  printf '%s' "$key" > "$ENGRAM_STATE_DIR/api-key"
  chmod 600 "$ENGRAM_STATE_DIR/api-key"
  umask "$old_umask"
  echo "file (~/.engram/api-key, chmod 600)"
}

# --- Helper: detect existing local (Ollama) install ---
local_installed() {
  command -v ollama &>/dev/null && \
    ollama list 2>/dev/null | grep -qE "^$OLLAMA_LOCAL_MODEL(\s|:)"
}

# --- Helper: detect existing api configuration ---
api_configured() {
  [[ -f "$ENGRAM_STATE_DIR/api-url" && -f "$ENGRAM_STATE_DIR/api-model" ]] && \
  ( (command -v security &>/dev/null && security find-generic-password \
       -a "$USER" -s "$KEYCHAIN_SERVICE" -w &>/dev/null) || \
    (command -v secret-tool &>/dev/null && secret-tool lookup \
       service "$KEYCHAIN_SERVICE" account "$USER" &>/dev/null) || \
    [[ -s "$ENGRAM_STATE_DIR/api-key" ]] )
}

# --- Helper: confirm re-install of same mode (interactive) ---
# Returns 0 if user confirms (wipe + reinstall), 1 if user cancels.
confirm_reinstall() {
  local mode_label="$1"
  echo ""
  echo "  ⚠ A ${mode_label} embedding configuration is already present."
  echo "    Re-installing will ERASE the existing ${mode_label} setup and reconfigure from scratch."
  echo ""
  local ans=""
  if [[ -r /dev/tty ]]; then
    read -rp "  Proceed with re-install? [y/N]: " ans </dev/tty || ans=""
  fi
  [[ "$ans" =~ ^[Yy]$ ]]
}

echo ""
echo "  ╔══════════════════════════════════════════╗"
echo "  ║     autoSDD v5.0 - Installer             ║"
echo "  ║     Extension for gentle-ai              ║"
echo "  ╚══════════════════════════════════════════╝"
echo ""

if [[ "$UPDATE_MODE" == true ]]; then
  echo "  → Update mode: keeping existing configuration, updating skills + CLAUDE.md"
  echo ""
  selected_agents=$(IFS=,; echo "${AGENTS[*]}")
  selected_persona=$(cat "$HOME/.engram/persona" 2>/dev/null || echo "neutral")
  embedding_mode=$(cat "$HOME/.engram/mode" 2>/dev/null || echo "none")
  embed_idx=0
  if [[ "$embedding_mode" == "api" ]]; then
    embed_idx=2
  fi
  reinstall_confirmed=false
fi

# --- Step 1: Agent Selection ---
if [[ "$UPDATE_MODE" != true ]]; then
echo "Step 1/3 - Select AI agents to configure"
echo "  (ENTER = all agents)"
echo ""
for i in "${!AGENTS[@]}"; do
  printf "  %2d. %s\n" $((i + 1)) "${AGENTS[$i]}"
done
echo ""

# Read from /dev/tty so prompts work under `curl … | bash` (stdin is the script, not the user).
# If /dev/tty isn't available (e.g. CI), fall back to defaults.
agent_input=""
if [[ -r /dev/tty ]]; then
  read -rp "  Agents (comma-separated numbers, e.g. 1,3,5): " agent_input </dev/tty || agent_input=""
fi

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
echo "Step 2/3 - Select AI response style"
echo "  (ENTER = neutral)"
echo ""
echo "  1. gentleman  - Rioplatense Spanish, passionate, opinionated"
echo "  2. neutral     - Professional, no regional style"
echo "  3. custom      - Define your own"
echo ""
persona_input=""
if [[ -r /dev/tty ]]; then
  read -rp "  Persona (1/2/3): " persona_input </dev/tty || persona_input=""
fi

selected_persona="neutral"
case "$persona_input" in
  1) selected_persona="gentleman" ;;
  2) selected_persona="neutral" ;;
  3) selected_persona="custom" ;;
  *) selected_persona="neutral" ;;
esac
echo "  → Selected: $selected_persona"
echo ""

# --- Step 3: Semantic search backend ---
echo "Step 3/3 - Semantic search backend for Engram"
echo "  (ENTER = local [default], 100% offline, no API key needed)"
echo ""
echo "  1. local        Ollama + bge-m3  (~2.3GB, free, offline)  [default]"
echo "  2. OpenAI       (${EMBED_PROVIDER_MODELS[1]})"
echo "  3. OpenRouter   (${EMBED_PROVIDER_MODELS[2]})"
echo "  4. Voyage AI    (${EMBED_PROVIDER_MODELS[3]})"
echo "  5. Mistral      (${EMBED_PROVIDER_MODELS[4]})"
echo "  6. Jina AI      (${EMBED_PROVIDER_MODELS[5]})"
echo ""

embed_input=""
if [[ -r /dev/tty ]]; then
  read -rp "  Backend (1-6): " embed_input </dev/tty || embed_input=""
fi

# Map input → embedding_mode and embed_idx (for api providers)
embedding_mode="local"
embed_idx=0
case "$embed_input" in
  ""|1) embedding_mode="local"; embed_idx=0 ;;
  2)   embedding_mode="api";   embed_idx=1 ;;
  3)   embedding_mode="api";   embed_idx=2 ;;
  4)   embedding_mode="api";   embed_idx=3 ;;
  5)   embedding_mode="api";   embed_idx=4 ;;
  6)   embedding_mode="api";   embed_idx=5 ;;
  *)   embedding_mode="local"; embed_idx=0 ;;
esac

echo "  → Selected: ${EMBED_PROVIDER_NAMES[$embed_idx]} (${EMBED_PROVIDER_MODELS[$embed_idx]:-$OLLAMA_LOCAL_MODEL})"
echo ""

# Re-install detection: warn if user picked a mode that's already configured.
reinstall_confirmed=false
if [[ "$embedding_mode" == "local" ]] && local_installed; then
  if confirm_reinstall "local (Ollama + $OLLAMA_LOCAL_MODEL)"; then
    reinstall_confirmed=true
  else
    echo "  → Local re-install cancelled; keeping existing config. Continuing with the rest of the install..."
    embedding_mode="keep"
  fi
elif [[ "$embedding_mode" == "api" ]] && api_configured; then
  if confirm_reinstall "api (${EMBED_PROVIDER_NAMES[$embed_idx]})"; then
    reinstall_confirmed=true
  else
    echo "  → API re-configuration cancelled; keeping existing config. Continuing with the rest of the install..."
    embedding_mode="keep"
  fi
fi
fi # end update mode guard for steps 1-3

# For api mode, collect and validate key up-front. Loops until valid.
api_key=""
if [[ "$UPDATE_MODE" != true ]] && [[ "$embedding_mode" == "api" ]]; then
  embed_url="${EMBED_PROVIDER_URLS[$embed_idx]}"
  embed_model="${EMBED_PROVIDER_MODELS[$embed_idx]}"
  echo ""
  echo "  You chose ${EMBED_PROVIDER_NAMES[$embed_idx]} with model ${embed_model}."
  echo "  Endpoint: ${embed_url}"
  echo ""
  if [[ ! -r /dev/tty ]]; then
    echo "  ✗ API mode requires an interactive terminal to enter the key safely."
    echo "    Re-run the installer attached to a terminal, or pick option 1 (local)."
    return 1
  fi
  while true; do
    api_key=""
    read -rs -p "  Enter API key for ${EMBED_PROVIDER_NAMES[$embed_idx]} (input hidden): " api_key </dev/tty || api_key=""
    echo ""
    if [[ -z "$api_key" ]]; then
      echo "  ✗ API key is required. Press Ctrl+C to abort."
      continue
    fi
    echo "  · Validating key by issuing a test embed request..."
    if validate_api_key "$embed_url" "$embed_model" "$api_key"; then
      echo "  ✓ Key is valid (endpoint responded 200)"
      break
    else
      echo "  ✗ Validation failed. The endpoint did not return 200 (check key, model access, or network)."
      echo "    Try again, or press Ctrl+C to abort."
    fi
  done
fi

if [[ "$UPDATE_MODE" == true ]]; then
  echo "Skipping prerequisites and dependency installation (update mode)..."
  mkdir -p "$ENGRAM_STATE_DIR" && chmod 700 "$ENGRAM_STATE_DIR" 2>/dev/null || true

  # Auto-configure embeddings if not yet configured and an API key is available
  mode_file="$ENGRAM_STATE_DIR/mode"
  current_mode=$(cat "$mode_file" 2>/dev/null || echo "")
  if [[ -z "$current_mode" || "$current_mode" == "none" ]]; then
    detected_key=""
    if [[ -n "${OPENROUTER_API_KEY:-}" ]]; then
      detected_key="$OPENROUTER_API_KEY"
    else
      for envf in ".env.local" ".env"; do
        if [[ -f "$envf" ]]; then
          detected_key=$(grep -E "^OPENROUTER_API_KEY=" "$envf" 2>/dev/null | head -1 | cut -d= -f2- | tr -d '"'"'"' ' || echo "")
          [[ -n "$detected_key" ]] && break
        fi
      done
    fi
    if [[ -n "$detected_key" ]]; then
      echo "  -> OPENROUTER_API_KEY detected, configuring API embeddings..."
      printf '%s' "https://openrouter.ai/api/v1/embeddings" > "$ENGRAM_STATE_DIR/api-url"
      printf '%s' "openai/text-embedding-3-small"            > "$ENGRAM_STATE_DIR/api-model"
      printf '%s' "OpenRouter"                               > "$ENGRAM_STATE_DIR/api-provider"
      store_api_key_secure "$detected_key" >/dev/null 2>&1
      printf '%s' "api" > "$mode_file"
      echo "  ✓ Embeddings configured via OpenRouter (key stored securely)"
      detected_key=""
    fi
  fi

  # Rebuild engram binary if embedding source exists
  embedding_dir="$HOME/.claude/plugins/marketplaces/engram/internal/embedding"
  if [[ -d "$embedding_dir" ]] && command -v go &>/dev/null; then
    engram_bin=$(command -v engram 2>/dev/null || echo "")
    if [[ -n "$engram_bin" ]]; then
      echo "  . Rebuilding engram binary with embedding support..."
      pushd "$HOME/.claude/plugins/marketplaces/engram" >/dev/null
      if go build -o "$engram_bin" ./cmd/engram/ 2>/dev/null; then
        echo "  ✓ Engram rebuilt"
      else
        echo "  ⚠ Engram rebuild failed (check Go installation)"
      fi
      popd >/dev/null
    fi
  fi
else
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
  echo "  · Node.js not found - installing via brew..."
  if ! brew install node; then
    echo "  ✗ Node.js installation failed."
    echo "  Install manually: https://nodejs.org/en/download"
    return 1
  fi
fi
echo "  ✓ node $(node --version 2>/dev/null)"

# Check Go (required by engram, installed by gentle-ai)
if ! command -v go &>/dev/null; then
  echo "  · Go not found - installing via brew..."
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
  echo "  · gentle-ai not found - installing via brew..."
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

# --- Inject Engram Embedding Layer ---
echo ""
echo "Injecting semantic search (embedding layer) into Engram..."

ENGRAM_SRC="$HOME/.claude/plugins/marketplaces/engram"
PATCH_URL="$REPO_URL/patches/engram-embedding.patch"

if [[ ! -d "$ENGRAM_SRC" ]]; then
  echo "  ⚠ Engram source not found at $ENGRAM_SRC"
  echo "  Semantic search will not be available until Engram is installed."
  warnings+=("Engram source not found - embedding layer skipped")
else
  # Check if embedding layer is already applied (idempotent)
  if [[ -d "$ENGRAM_SRC/internal/embedding" ]]; then
    echo "  ✓ Embedding layer already applied - skipping patch"
  else
    # Download and apply patch
    patch_tmp=$(mktemp /tmp/engram-embedding-XXXXXX.patch)
    if curl -fsSL -o "$patch_tmp" "$PATCH_URL"; then
      cd "$ENGRAM_SRC"
      if git apply --check "$patch_tmp" 2>/dev/null; then
        git apply "$patch_tmp"
        echo "  ✓ Embedding patch applied"
      else
        echo "  ⚠ Patch does not apply cleanly (Engram version may have changed)"
        echo "  Trying with 3-way merge..."
        if git apply --3way "$patch_tmp" 2>/dev/null; then
          echo "  ✓ Embedding patch applied (3-way merge)"
        else
          echo "  ⚠ Embedding patch failed - semantic search not available"
          warnings+=("Embedding patch failed to apply")
          rm -f "$patch_tmp"
          cd - >/dev/null
        fi
      fi
      rm -f "$patch_tmp"
      cd - >/dev/null
    else
      echo "  ⚠ Failed to download embedding patch"
      warnings+=("Failed to download embedding patch from $PATCH_URL")
    fi
  fi

  # Rebuild engram binary if embedding layer exists
  if [[ -d "$ENGRAM_SRC/internal/embedding" ]]; then
    echo "  · Rebuilding engram binary with embedding support..."

    # Find current engram binary location
    engram_bin=$(command -v engram 2>/dev/null || echo "")
    if [[ -z "$engram_bin" ]]; then
      engram_bin="$(go env GOPATH 2>/dev/null)/bin/engram"
    fi

    cd "$ENGRAM_SRC"
    if go build -o "$engram_bin" ./cmd/engram/ 2>/dev/null; then
      echo "  ✓ Engram rebuilt with semantic search support"
    else
      echo "  ⚠ Engram rebuild failed - check Go installation"
      warnings+=("Engram rebuild failed - embedding layer applied but binary not updated")
    fi
    cd - >/dev/null
  fi
fi

# --- Configure Embedding Backend (local Ollama or remote API) ---
# Dual-mode design: both configurations can coexist. A wrapper script reads
# ~/.engram/mode at each MCP launch to select which backend is active.
# Switching modes does NOT wipe the other mode's config.
echo ""
echo "Configuring embedding backend..."

mkdir -p "$ENGRAM_STATE_DIR" && chmod 700 "$ENGRAM_STATE_DIR"

# Install Ollama + pull bge-m3 for local mode (skips if already present, unless reinstall confirmed)
if [[ "$embedding_mode" == "local" ]]; then
  if $reinstall_confirmed; then
    echo "  · Wiping previous local setup (model only; Ollama binary is preserved)..."
    ollama rm "$OLLAMA_LOCAL_MODEL" 2>/dev/null || true
  fi

  if ! command -v ollama &>/dev/null; then
    echo "  · Installing Ollama (~40MB)..."
    if curl -fsSL https://ollama.com/install.sh | sh; then
      echo "  ✓ Ollama installed"
    else
      echo "  ⚠ Ollama install failed - semantic search will fall back to TF-IDF"
      warnings+=("Ollama install failed - local embedding mode unavailable")
      embedding_mode="none"
    fi
  else
    echo "  ✓ Ollama already present"
  fi

  if [[ "$embedding_mode" == "local" ]]; then
    # Ensure ollama daemon is running. Linux systemd unit is typical; fall back to nohup.
    if ! curl -sSf http://localhost:11434/api/tags >/dev/null 2>&1; then
      echo "  · Starting Ollama service in background..."
      if command -v systemctl &>/dev/null && systemctl list-unit-files ollama.service &>/dev/null; then
        systemctl start ollama 2>/dev/null || nohup ollama serve >/dev/null 2>&1 &
      else
        nohup ollama serve >/dev/null 2>&1 &
      fi
      # Wait up to 10s for the daemon
      for i in 1 2 3 4 5 6 7 8 9 10; do
        curl -sSf http://localhost:11434/api/tags >/dev/null 2>&1 && break
        sleep 1
      done
    fi

    # Pull model (idempotent - skips if already local)
    if ollama list 2>/dev/null | grep -qE "^$OLLAMA_LOCAL_MODEL(\s|:)"; then
      echo "  ✓ Model $OLLAMA_LOCAL_MODEL already present"
    else
      echo "  · Pulling $OLLAMA_LOCAL_MODEL (~2.3GB, this may take several minutes)..."
      if ollama pull "$OLLAMA_LOCAL_MODEL"; then
        echo "  ✓ Model $OLLAMA_LOCAL_MODEL pulled"
      else
        echo "  ⚠ Model pull failed - semantic search will fall back to TF-IDF"
        warnings+=("Ollama pull $OLLAMA_LOCAL_MODEL failed")
        embedding_mode="none"
      fi
    fi
  fi
fi

# Store API credentials for api mode
if [[ "$embedding_mode" == "api" ]]; then
  echo "$embed_url"   > "$ENGRAM_STATE_DIR/api-url"
  echo "$embed_model" > "$ENGRAM_STATE_DIR/api-model"
  echo "${EMBED_PROVIDER_NAMES[$embed_idx]}" > "$ENGRAM_STATE_DIR/api-provider"

  store_method=$(store_api_key_secure "$api_key")
  echo "  ✓ API key stored in: $store_method"
  # Clear the variable from shell memory
  api_key=""
  unset api_key
fi

# Write the active mode marker AFTER successful configuration of the chosen mode.
# If user chose "keep" (re-install cancelled), the existing mode file is untouched.
if [[ "$embedding_mode" != "keep" ]]; then
  echo "$embedding_mode" > "$ENGRAM_STATE_DIR/mode"
fi

fi # end update mode guard for prerequisites + dependencies

# Write the wrapper script that selects the backend at each MCP launch.
cat > "$ENGRAM_STATE_DIR/engram-wrapper.sh" <<WRAPPER_EOF
#!/usr/bin/env bash
# Managed by autoSDD installer - do not edit directly.
# Selects the embedding backend (local Ollama or remote API) based on
# \$HOME/.engram/mode, then execs engram mcp with the right env vars.

MODE=\$(tr -d '[:space:]' < "\$HOME/.engram/mode" 2>/dev/null || echo "local")
KEYCHAIN_SERVICE="$KEYCHAIN_SERVICE"
OLLAMA_URL="$OLLAMA_LOCAL_URL"
OLLAMA_MODEL="$OLLAMA_LOCAL_MODEL"

resolve_openrouter_key() {
  local k=""
  if [[ -n "\$OPENROUTER_API_KEY" ]]; then
    k="\$OPENROUTER_API_KEY"
  else
    local envf
    for envf in ".env.local" ".env"; do
      if [[ -f "\$envf" ]]; then
        k=\$(grep -E "^OPENROUTER_API_KEY=" "\$envf" 2>/dev/null | head -1 | cut -d= -f2- | tr -d '"'"'"' ' || echo "")
        [[ -n "\$k" ]] && break
      fi
    done
  fi
  printf '%s' "\$k"
}

case "\$MODE" in
  local)
    export ENGRAM_EMBEDDING_PROVIDER=api
    export ENGRAM_EMBEDDING_API_URL="\$OLLAMA_URL"
    export ENGRAM_EMBEDDING_API_MODEL="\$OLLAMA_MODEL"
    export ENGRAM_EMBEDDING_API_KEY=ollama
    ;;
  api)
    export ENGRAM_EMBEDDING_PROVIDER=api
    export ENGRAM_EMBEDDING_API_URL=\$(cat "\$HOME/.engram/api-url" 2>/dev/null)
    export ENGRAM_EMBEDDING_API_MODEL=\$(cat "\$HOME/.engram/api-model" 2>/dev/null)
    key=""
    if command -v security >/dev/null 2>&1; then
      key=\$(security find-generic-password -a "\$USER" -s "\$KEYCHAIN_SERVICE" -w 2>/dev/null || echo "")
    fi
    if [[ -z "\$key" ]] && command -v secret-tool >/dev/null 2>&1; then
      key=\$(secret-tool lookup service "\$KEYCHAIN_SERVICE" account "\$USER" 2>/dev/null || echo "")
    fi
    if [[ -z "\$key" ]] && [[ -f "\$HOME/.engram/api-key" ]]; then
      key=\$(cat "\$HOME/.engram/api-key" 2>/dev/null || echo "")
    fi
    if [[ -z "\$key" ]]; then
      key=\$(resolve_openrouter_key)
    fi
    export ENGRAM_EMBEDDING_API_KEY="\$key"
    ;;
  *)
    key=\$(resolve_openrouter_key)
    if [[ -n "\$key" ]]; then
      export ENGRAM_EMBEDDING_PROVIDER=api
      export ENGRAM_EMBEDDING_API_URL="https://openrouter.ai/api/v1/embeddings"
      export ENGRAM_EMBEDDING_API_MODEL="openai/text-embedding-3-small"
      export ENGRAM_EMBEDDING_API_KEY="\$key"
    else
      export ENGRAM_EMBEDDING_PROVIDER=local
    fi
    ;;
esac

engram_bin=\$(command -v engram 2>/dev/null)
if [[ -z "\$engram_bin" ]]; then
  echo "engram binary not found in PATH - cannot start MCP server" >&2
  exit 1
fi
exec "\$engram_bin" mcp --tools=agent "\$@"
WRAPPER_EOF
chmod 755 "$ENGRAM_STATE_DIR/engram-wrapper.sh"
echo "  ✓ Wrapper installed at $ENGRAM_STATE_DIR/engram-wrapper.sh"

# Point Claude Code's MCP config at the wrapper so the right env vars load at launch.
# Other agents continue to use the default engram invocation (TF-IDF fallback).

# User-level MCP override
claude_mcp="$HOME/.claude/mcp/engram.json"
if [[ -d "$HOME/.claude/mcp" ]]; then
  cat > "$claude_mcp" <<EOF
{
  "command": "$ENGRAM_STATE_DIR/engram-wrapper.sh",
  "args": []
}
EOF
  echo "  ✓ Claude Code MCP config rewired to wrapper"
else
  echo "  ⚠ $HOME/.claude/mcp not found - skipped MCP rewire"
fi

# Plugin cache MCP override (plugin config takes precedence over user-level)
plugin_mcp="$HOME/.claude/plugins/cache/engram/engram"
if [[ -d "$plugin_mcp" ]]; then
  for ver_dir in "$plugin_mcp"/*/; do
    mcp_json="$ver_dir.mcp.json"
    if [[ -f "$mcp_json" ]]; then
      cat > "$mcp_json" <<EOF
{
  "mcpServers": {
    "engram": {
      "command": "$ENGRAM_STATE_DIR/engram-wrapper.sh",
      "args": []
    }
  }
}
EOF
      echo "  ✓ Engram plugin config rewired to wrapper ($(basename "$ver_dir"))"
    fi
  done
fi

# Report active mode
active_mode=$(cat "$ENGRAM_STATE_DIR/mode" 2>/dev/null || echo "local")
echo "  → Active embedding mode: $active_mode"

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

# --- Install core skills globally ---
echo ""
echo "Installing core skills (global)..."

installed_skill_paths=()

# 1. Install autoSDD skill directly (from this repo)
for i in "${!AGENTS[@]}"; do
  agent="${AGENTS[$i]}"
  if echo "$selected_agents" | grep -q "$agent"; then
    skill_dir="${AGENT_DIRS[$i]}/skills/autosdd"
    mkdir -p "$skill_dir"
    if curl -fsSL -o "$skill_dir/SKILL.md" "$REPO_URL/skill/SKILL.md"; then
      installed_skill_paths+=("$skill_dir/SKILL.md")
      echo "  ✓ autosdd ($agent)"
    else
      msg="Failed to install autosdd for $agent"
      echo "  ⚠ $msg"
      warnings+=("$msg")
    fi
  fi
done

# 1b. Install autosdd-telemetry skill (from this repo)
for i in "${!AGENTS[@]}"; do
  agent="${AGENTS[$i]}"
  if echo "$selected_agents" | grep -q "$agent"; then
    skill_dir="${AGENT_DIRS[$i]}/skills/autosdd-telemetry"
    mkdir -p "$skill_dir"
    if curl -fsSL -o "$skill_dir/SKILL.md" "$REPO_URL/skills/autosdd-telemetry/SKILL.md"; then
      echo "  ✓ autosdd-telemetry ($agent)"
    else
      msg="Failed to install autosdd-telemetry for $agent"
      echo "  ⚠ $msg"
      warnings+=("$msg")
    fi
  fi
done

# 2. Install remaining core skills via skills.sh (canonical sources)
SKILLS_SH=(
  "https://github.com/wshobson/agents:prompt-engineering-patterns"
  "https://github.com/anthropics/skills:frontend-design"
  "https://github.com/dammyjay93/interface-design:interface-design"
  "https://github.com/anthropics/claude-plugins-official:claude-md-improver"
  "https://github.com/wshobson/agents:e2e-testing-patterns"
  "https://github.com/wshobson/agents:error-handling-patterns"
  "https://github.com/microsoft/playwright-cli:playwright-cli"
)

for entry in "${SKILLS_SH[@]}"; do
  # Split on the LAST ':' so the 'https://' prefix isn't mangled.
  # %:*  = drop shortest suffix starting at ':'  → everything before the last ':' (the repo URL)
  # ##*: = drop longest prefix ending at ':'     → everything after the last ':' (the skill name)
  repo="${entry%:*}"
  skill="${entry##*:}"
  echo "  · Installing $skill..."
  if npx -y skills add "$repo" --skill "$skill" -g -y 2>/dev/null; then
    echo "  ✓ $skill"
  else
    msg="Failed to install $skill via skills.sh"
    echo "  ⚠ $msg"
    warnings+=("$msg")
  fi
done

# 3. Install bundled skills (from autoSDD repo itself)
BUNDLED_SKILLS=("feedback-report" "knowledge-graph")
for skill in "${BUNDLED_SKILLS[@]}"; do
  for i in "${!AGENTS[@]}"; do
    agent="${AGENTS[$i]}"
    if echo "$selected_agents" | grep -q "$agent"; then
      skill_dir="${AGENT_DIRS[$i]}/skills/$skill"
      mkdir -p "$skill_dir"
      if curl -fsSL -o "$skill_dir/SKILL.md" "$REPO_URL/skills/$skill/SKILL.md"; then
        echo "  ✓ $skill ($agent)"
      else
        msg="Failed to install $skill for $agent"
        echo "  ⚠ $msg"
        warnings+=("$msg")
      fi
    fi
  done
done

# 4. Install RTK shared protocol (autoSDD-specific, gentle-ai owns the rest of _shared/)
echo ""
echo "Installing RTK shared protocol..."
for i in "${!AGENTS[@]}"; do
  agent="${AGENTS[$i]}"
  if echo "$selected_agents" | grep -q "$agent"; then
    shared_dir="${AGENT_DIRS[$i]}/skills/_shared"
    mkdir -p "$shared_dir"
    if curl -fsSL -o "$shared_dir/rtk.md" "$REPO_URL/shared/rtk.md" 2>/dev/null; then
      echo "  ✓ rtk.md ($agent)"
    else
      msg="Failed to install shared/rtk.md for $agent"
      warnings+=("$msg")
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

# --- Bootstrap project templates ---
echo ""
echo "Bootstrapping project templates..."

TEMPLATE_URL="$REPO_URL/templates"
CONTEXT_DIR="./context"

if [[ -d "$CONTEXT_DIR" ]]; then
  echo "  context/ directory already exists - skipping existing files"
fi

mkdir -p "$CONTEXT_DIR"

templates=("guidelines.md" "user_context.md" "business_logic.md" "autosdd.md")
for tmpl in "${templates[@]}"; do
  target="$CONTEXT_DIR/$tmpl"
  if [[ -f "$target" ]]; then
    echo "  · $tmpl already exists - skipped"
  else
    if curl -fsSL -o "$target" "$TEMPLATE_URL/$tmpl"; then
      echo "  ✓ $tmpl → $target"
    else
      echo "  ⚠ Failed to download $tmpl"
    fi
  fi
done

# Install knowledge-graph HTML viewer (static template, always overwrite to keep up-to-date)
kg_html="$CONTEXT_DIR/knowledge-graph.html"
if curl -fsSL -o "$kg_html" "$TEMPLATE_URL/knowledge-graph.html"; then
  echo "  ✓ knowledge-graph.html → $kg_html"
else
  echo "  ⚠ Failed to download knowledge-graph.html viewer"
fi

# --- Inject autoSDD block into CLAUDE.md ---

# Build skill path references for all selected agents
skill_refs=""
for p in "${installed_skill_paths[@]}"; do
  skill_refs="${skill_refs}
- \`$p\`"
done

AUTOSDD_BLOCK="<!-- autosdd:start -->
## autoSDD v5.0 - Active Framework (DO NOT REMOVE)

autoSDD v5.0 is the ACTIVE development framework. ALL prompts go through autoSDD unless opted out with \`[raw]\`, \`[no-sdd]\`, or \`skip autosdd\`.

Foundation layer (SDD phases, MCPs, shared protocols) provided by **gentle-ai**. autoSDD extends it with the meta-framework, telemetry, and additional skills.

### Core Rule
**The orchestrator DELEGATES. It never writes source code (.ts, .tsx, .prisma, etc.) inline.** See SKILL.md Section 1.

### Pipeline
Triage -> Route -> Plan (CREA prompt.md) -> Delegate (sub-agents with skill injection) -> Collect -> Close Version -> Knowledge Update -> Compaction Check

### Key Sections to Internalize
- **Section 1**: Orchestrator identity (delegate, don't execute)
- **Section 3**: CREA applied ONCE on prompt.md (not 3x)
- **Section 4**: Sub-agent launch template (fill-in-the-blank, mandatory)
- **Section 5**: Skill routing (pattern match -> inject rules)
- **Step 8**: Compaction protocol (suggest /compact at >50% context)

### Ecosystem

#### Skills installed by autoSDD
| Skill | When |
|-------|------|
| \`autosdd\` | ALWAYS - flow router + CREA + feedback engine |
| \`autosdd-telemetry\` | ALWAYS - pipeline metrics and analytics |
| \`prompt-engineering-patterns\` | Every prompt creation - CREA techniques |
| \`frontend-design\` | Public-facing UI - pages, components |
| \`interface-design\` | Admin/internal UI - dashboards, tables |
| \`e2e-testing-patterns\` | E2E tests - Playwright/Cypress |
| \`error-handling-patterns\` | Error management - API routes, validation |
| \`playwright-cli\` | Browser automation (ALWAYS --headed) |
| \`claude-md-improver\` | CLAUDE.md - audit, improve |
| \`feedback-report\` | \`/feedback [timerange]\` - improvement reports |
| \`knowledge-graph\` | \`/knowledge-graph\` - memory visualization |

#### Skills provided by gentle-ai (DO NOT reinstall)
\`branch-pr\` · \`judgment-day\` · \`skill-creator\` · \`issue-creation\` · \`skill-registry\` · \`go-testing\`

#### SDD Phases (via gentle-ai)
\`sdd-init\` · \`sdd-explore\` · \`sdd-propose\` · \`sdd-spec\` · \`sdd-design\` · \`sdd-tasks\` · \`sdd-apply\` · \`sdd-verify\` · \`sdd-archive\` · \`sdd-onboard\`

#### MCPs (via gentle-ai + autoSDD embedding layer)
Engram (memory + semantic search) · Context7 (docs) · Playwright (browser) · Prisma (DB) · Linear (issues) · GitHub (PRs)

#### Tools
RTK: ALWAYS prefix with \`rtk\` (60-90% savings) · Monitor: event-driven waiting (NEVER poll)

### Three Critical Context Files (sacred, auto-updated)
- \`context/guidelines.md\` - Technical rules and conventions
- \`context/user_context.md\` - User profile and preferences
- \`context/business_logic.md\` - Domain knowledge and workflows

### Bidirectional Feedback (v5)
- AI analyzes EVERY prompt for quality, skill gaps, optimization opportunities
- User feedback detected and persisted automatically
- Telemetry tracks pipeline stages, routing decisions, and token usage
- \`feedback.md\` auto-generated at version close
- \`/feedback [timerange]\` for reports · \`/knowledge-graph\` for memory visualization

### Shared Protocols (gentle-ai owns _shared/, autoSDD adds rtk.md only)
| Protocol | File |
|----------|------|
| RTK Token Optimization | \`~/.claude/skills/_shared/rtk.md\` |
| Persona & Rules | \`~/.claude/skills/_shared/persona.md\` (gentle-ai) |
| SDD Orchestrator | \`~/.claude/skills/_shared/sdd-orchestrator.md\` (gentle-ai) |
| Engram Memory | \`~/.claude/skills/_shared/engram-protocol.md\` (gentle-ai) |

Read the full framework: \`~/.claude/skills/autosdd/SKILL.md\`
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
    # v4+/v5+ with markers → replace marked block
    sed -i '/<!-- autosdd:start -->/,/<!-- autosdd:end -->/d' "./CLAUDE.md"
    printf '%s\n' "$AUTOSDD_BLOCK" >> "./CLAUDE.md"
    echo "  ✓ CLAUDE.md → autoSDD block updated (markers replaced)"
  elif grep -q "^## autoSDD" "./CLAUDE.md"; then
    # v2/v3 without markers → replace from section header to end of file
    sed -i '/^## autoSDD/,$d' "./CLAUDE.md"
    printf '%s\n' "$AUTOSDD_BLOCK" >> "./CLAUDE.md"
    echo "  ✓ CLAUDE.md → old autoSDD section replaced (markers added)"
  else
    # No autoSDD section → append
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
  echo "  [..] engram NOT in PATH - restart your terminal"
fi

# Check RTK
if command -v rtk &>/dev/null; then
  echo "  [OK] RTK"
else
  echo "  [..] RTK not in PATH - restart terminal or install: cargo install rtk"
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
      echo "  [OK] SDD skills ($agent) - all 9 installed"
    else
      echo "  [!!] SDD skills ($agent) - MISSING: ${missing_skills[*]}"
      all_good=false
    fi

    # Check core skills installed by autoSDD (via skills.sh -g)
    core_skill_names=("autosdd" "autosdd-telemetry" "prompt-engineering-patterns" "frontend-design" "interface-design" "claude-md-improver" "e2e-testing-patterns" "error-handling-patterns" "playwright-cli" "feedback-report" "knowledge-graph")
    for cs in "${core_skill_names[@]}"; do
      cs_path="${AGENT_DIRS[$i]}/skills/$cs/SKILL.md"
      if [[ -f "$cs_path" ]]; then
        echo "  [OK] $cs ($agent)"
      else
        echo "  [!!] $cs MISSING ($agent)"
        warnings+=("$cs skill not found at $cs_path")
        all_good=false
      fi
    done
    break
  fi
done

# Check embedding layer (Go patch applied + binary rebuilt)
if [[ -d "$HOME/.claude/plugins/marketplaces/engram/internal/embedding" ]]; then
  echo "  [OK] Engram embedding layer"
else
  echo "  [..] Engram embedding layer not applied"
fi

# Check embedding backend configuration
if [[ -f "$ENGRAM_STATE_DIR/mode" && -x "$ENGRAM_STATE_DIR/engram-wrapper.sh" ]]; then
  active=$(cat "$ENGRAM_STATE_DIR/mode" 2>/dev/null || echo "?")
  case "$active" in
    local)
      if command -v ollama &>/dev/null && \
         ollama list 2>/dev/null | grep -qE "^$OLLAMA_LOCAL_MODEL(\s|:)"; then
        echo "  [OK] Embedding backend: local ($OLLAMA_LOCAL_MODEL via Ollama)"
      else
        echo "  [!!] Embedding backend: local but Ollama/bge-m3 missing"
        all_good=false
      fi
      ;;
    api)
      provider=$(cat "$ENGRAM_STATE_DIR/api-provider" 2>/dev/null || echo "?")
      model=$(cat "$ENGRAM_STATE_DIR/api-model" 2>/dev/null || echo "?")
      echo "  [OK] Embedding backend: api ($provider, $model)"
      ;;
    *)
      echo "  [..] Embedding backend: $active (no semantic search, TF-IDF fallback)"
      ;;
  esac
else
  echo "  [..] Embedding backend not configured"
fi

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
  echo "  ║     autoSDD v5.0 installed!               ║"
  echo "  ╚══════════════════════════════════════════╝"
else
  echo "  ╔══════════════════════════════════════════╗"
  echo "  ║  autoSDD v5.0 installed (with warnings)   ║"
  echo "  ╚══════════════════════════════════════════╝"
fi

# Show collected warnings/errors
if [[ ${#warnings[@]} -gt 0 ]]; then
  echo ""
  echo "  Warnings/Errors during installation:"
  echo "  ------------------------------------"
  for w in "${warnings[@]}"; do
    echo "  - $w"
  done
  echo ""
  echo "  If re-running the installer doesn't fix these:"
  echo "    Report:  https://github.com/thestark77/autosdd/issues/new"
  echo "    Fix it:  https://github.com/thestark77/autosdd/pulls"
  echo ""
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
unset -f _autosdd_install 2>/dev/null || true
