#!/usr/bin/env bash
set -uo pipefail

# autoSDD automation script — managed by installer
# version-init.sh — Mechanical VERSION INIT for pipeline Step 0
#
# Usage:
#   version-init.sh [VERSION]
#
# If VERSION is omitted, reads PROGRESS.md and increments the latest patch number.
# Outputs the version string (e.g. "6.0.1") to stdout on success.
#
# Environment:
#   PROJECT_ROOT  Override project root (default: script's grandparent directory)

# ── Resolve project root ─────────────────────────────────────────────────────

if [[ -n "${PROJECT_ROOT:-}" ]]; then
  ROOT="$PROJECT_ROOT"
else
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

PROGRESS="$ROOT/PROGRESS.md"
VERSIONS_DIR="$ROOT/context/appVersions"

# ── Determine version ────────────────────────────────────────────────────────

if [[ $# -ge 1 && -n "$1" ]]; then
  VERSION="$1"
else
  # Auto-increment: find latest v line in PROGRESS.md
  if [[ ! -f "$PROGRESS" ]]; then
    echo "ERROR: PROGRESS.md not found at $PROGRESS and no version argument provided" >&2
    exit 1
  fi

  LATEST=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' "$PROGRESS" | head -1 || true)

  if [[ -z "$LATEST" ]]; then
    echo "ERROR: No version pattern (vX.Y.Z) found in PROGRESS.md" >&2
    exit 1
  fi

  # Strip leading 'v' and split
  LATEST="${LATEST#v}"
  IFS='.' read -r MAJOR MINOR PATCH <<< "$LATEST"
  PATCH=$((PATCH + 1))
  VERSION="${MAJOR}.${MINOR}.${PATCH}"
fi

# Validate version format
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "ERROR: Invalid version format '$VERSION'. Expected X.Y.Z" >&2
  exit 1
fi

# ── Create version directory ─────────────────────────────────────────────────

VERSION_DIR="$VERSIONS_DIR/v${VERSION}"
mkdir -p "$VERSION_DIR"

# ── Reset PROGRESS.md ────────────────────────────────────────────────────────

cat > "$PROGRESS" << EOF
# PROGRESS

## v${VERSION} — STARTED
EOF

# ── Output version ───────────────────────────────────────────────────────────

echo "$VERSION"
exit 0
