#!/usr/bin/env bash
set -euo pipefail

# autosdd-resume v1.0.0
# Claude CLI wrapper with automatic rate-limit recovery.
# Part of autoSDD. Enabled by default.
#
# Usage: autosdd-resume [--no-resume] [--ar-version] [claude args...]
#
# Environment:
#   AUTOSDD_AUTO_RESUME=false  Disable auto-resume (passthrough to claude)
#   AUTOSDD_MAX_RETRIES=10     Max retry attempts (default: 10)
#   AUTOSDD_BUFFER_SECS=30     Extra seconds after detected reset time (default: 30)
#   AUTOSDD_DEFAULT_WAIT=120   Default wait when reset time can't be parsed (default: 120)

VERSION="1.0.0"
MAX_RETRIES="${AUTOSDD_MAX_RETRIES:-10}"
BUFFER_SECS="${AUTOSDD_BUFFER_SECS:-30}"
DEFAULT_WAIT="${AUTOSDD_DEFAULT_WAIT:-120}"

no_resume=false
claude_args=()

for arg in "$@"; do
  case "$arg" in
    --no-resume)  no_resume=true ;;
    --ar-version) echo "autosdd-resume v${VERSION}"; exit 0 ;;
    *)            claude_args+=("$arg") ;;
  esac
done

# Passthrough if disabled
if [[ "${AUTOSDD_AUTO_RESUME:-true}" == "false" ]] || $no_resume; then
  exec claude "${claude_args[@]+"${claude_args[@]}"}"
fi

# Inject --dangerously-skip-permissions if absent
has_flag=false
for a in "${claude_args[@]+"${claude_args[@]}"}"; do
  [[ "$a" == "--dangerously-skip-permissions" ]] && has_flag=true
done
$has_flag || claude_args=(--dangerously-skip-permissions "${claude_args[@]+"${claude_args[@]}"}")

# ── Utilities ─────────────────────────────────────────────────────────────────

strip_ansi() {
  sed $'s/\x1b\[[0-9;]*[a-zA-Z]//g; s/\r//g'
}

is_rate_limited() {
  echo "$1" | strip_ansi | grep -qiE 'rate.?limit|hit.?(your|the).?limit|resets?\s+[0-9]' 2>/dev/null
}

parse_wait_secs() {
  local clean time_str reset_epoch now_epoch wait
  clean=$(echo "$1" | strip_ansi)
  time_str=$(echo "$clean" | grep -oiE '[0-9]{1,2}:[0-9]{2}\s*(am|pm)?' | head -1) || true

  [[ -z "$time_str" ]] && { echo "$DEFAULT_WAIT"; return; }

  # GNU date (Linux)
  reset_epoch=$(date -d "$time_str" +%s 2>/dev/null) || \
  # BSD date (macOS) — 12h
  reset_epoch=$(date -j -f "%I:%M%p" "$(echo "$time_str" | tr -d ' ' | tr '[:lower:]' '[:upper:]')" +%s 2>/dev/null) || \
  # BSD date (macOS) — 24h
  reset_epoch=$(date -j -f "%H:%M" "$time_str" +%s 2>/dev/null) || \
  { echo "$DEFAULT_WAIT"; return; }

  now_epoch=$(date +%s)
  wait=$((reset_epoch - now_epoch + BUFFER_SECS))
  (( wait < 30 )) && wait=$DEFAULT_WAIT
  (( wait > 3600 )) && wait=3600
  echo "$wait"
}

countdown() {
  local s=$1
  while (( s > 0 )); do
    printf "\r  Resuming in %02d:%02d " $((s/60)) $((s%60))
    sleep 1
    (( s-- ))
  done
  printf "\r  Resuming now...                   \n"
}

run_capture() {
  local outfile=$1; shift
  if [[ "$(uname -s)" == "Darwin" ]]; then
    script -q "$outfile" "$@" || return $?
  elif command -v script &>/dev/null; then
    script -qec "$(printf '%q ' "$@")" "$outfile" || return $?
  else
    "$@" 2>&1 | tee "$outfile" || return $?
  fi
}

# ── Main loop ─────────────────────────────────────────────────────────────────

attempt=0
is_resume=false

while (( attempt < MAX_RETRIES )); do
  outfile=$(mktemp "${TMPDIR:-/tmp}/autosdd-resume.XXXXXX")
  rc=0

  if $is_resume; then
    run_capture "$outfile" claude --dangerously-skip-permissions -c || rc=$?
  else
    run_capture "$outfile" claude "${claude_args[@]}" || rc=$?
  fi

  output=$(cat "$outfile" 2>/dev/null || true)
  rm -f "$outfile"

  if is_rate_limited "$output"; then
    (( attempt++ ))
    echo ""
    echo "  [autosdd-resume] Rate limit hit (attempt $attempt/$MAX_RETRIES)"
    wait=$(parse_wait_secs "$output")
    echo "  [autosdd-resume] Waiting ${wait}s for reset..."
    countdown "$wait"
    is_resume=true
  else
    exit "$rc"
  fi
done

echo "  [autosdd-resume] Max retries ($MAX_RETRIES) reached."
exit 1
