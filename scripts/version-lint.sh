#!/usr/bin/env bash
set -uo pipefail

# autoSDD automation script — managed by installer
# version-lint.sh — Verify sync paths at version close (Step 6/7)
#
# Usage:
#   version-lint.sh VERSION
#
# Checks version strings across all sync-path files and reports PASS/FAIL.
# Exit 0 if all pass, exit 1 if any fail.
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

# ── Validate arguments ───────────────────────────────────────────────────────

if [[ $# -lt 1 || -z "$1" ]]; then
  echo "Usage: version-lint.sh VERSION" >&2
  echo "  e.g. version-lint.sh 6.0.0" >&2
  exit 1
fi

VERSION="$1"

if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "ERROR: Invalid version format '$VERSION'. Expected X.Y.Z" >&2
  exit 1
fi

# Major.Minor for block version strings (e.g. "autoSDD v6.0")
MAJOR_MINOR=$(echo "$VERSION" | grep -oE '^[0-9]+\.[0-9]+')

# ── Check helpers ────────────────────────────────────────────────────────────

FAILURES=0
WARNINGS=0
TOTAL=0

pass() {
  TOTAL=$((TOTAL + 1))
  echo "  PASS  $1"
}

fail() {
  TOTAL=$((TOTAL + 1))
  FAILURES=$((FAILURES + 1))
  echo "  FAIL  $1"
}

warn() {
  TOTAL=$((TOTAL + 1))
  WARNINGS=$((WARNINGS + 1))
  echo "  WARN  $1"
}

# ── Checks ───────────────────────────────────────────────────────────────────

echo ""
echo "autoSDD version-lint — checking v${VERSION}"
echo "================================================"
echo ""

# 1. SKILL.md frontmatter version
SKILL_FILE="$ROOT/skill/SKILL.md"
if [[ -f "$SKILL_FILE" ]]; then
  if grep -qE "^version:\s*\"${VERSION}\"" "$SKILL_FILE"; then
    pass "skill/SKILL.md contains version: \"${VERSION}\""
  else
    fail "skill/SKILL.md does NOT contain version: \"${VERSION}\""
  fi
else
  fail "skill/SKILL.md not found"
fi

# 2. templates/CLAUDE.md autoSDD block version
TEMPLATE_FILE="$ROOT/templates/CLAUDE.md"
if [[ -f "$TEMPLATE_FILE" ]]; then
  if grep -qF "autoSDD v${MAJOR_MINOR}" "$TEMPLATE_FILE"; then
    pass "templates/CLAUDE.md contains autoSDD v${MAJOR_MINOR}"
  else
    fail "templates/CLAUDE.md does NOT contain autoSDD v${MAJOR_MINOR}"
  fi
else
  fail "templates/CLAUDE.md not found"
fi

# 3. install.sh AUTOSDD_BLOCK version
INSTALL_SH="$ROOT/install.sh"
if [[ -f "$INSTALL_SH" ]]; then
  if grep -qF "autoSDD v${MAJOR_MINOR}" "$INSTALL_SH"; then
    pass "install.sh contains autoSDD v${MAJOR_MINOR}"
  else
    fail "install.sh does NOT contain autoSDD v${MAJOR_MINOR}"
  fi
else
  fail "install.sh not found"
fi

# 4. install.ps1 AUTOSDD_BLOCK version
INSTALL_PS1="$ROOT/install.ps1"
if [[ -f "$INSTALL_PS1" ]]; then
  if grep -qF "autoSDD v${MAJOR_MINOR}" "$INSTALL_PS1"; then
    pass "install.ps1 contains autoSDD v${MAJOR_MINOR}"
  else
    fail "install.ps1 does NOT contain autoSDD v${MAJOR_MINOR}"
  fi
else
  fail "install.ps1 not found"
fi

# 5. Version directory exists
VERSION_DIR="$ROOT/context/appVersions/v${VERSION}"
if [[ -d "$VERSION_DIR" ]]; then
  pass "context/appVersions/v${VERSION}/ exists"
else
  fail "context/appVersions/v${VERSION}/ does NOT exist"
fi

# 6. feedback.md exists (warn only)
FEEDBACK_FILE="$VERSION_DIR/feedback.md"
if [[ -f "$FEEDBACK_FILE" ]]; then
  pass "context/appVersions/v${VERSION}/feedback.md exists"
else
  warn "context/appVersions/v${VERSION}/feedback.md is missing (not a hard failure)"
fi

# 7. SKILL.md under 300 lines
if [[ -f "$SKILL_FILE" ]]; then
  LINE_COUNT=$(wc -l < "$SKILL_FILE" | tr -d ' ')
  if [[ "$LINE_COUNT" -lt 300 ]]; then
    pass "skill/SKILL.md is ${LINE_COUNT} lines (< 300 limit)"
  else
    fail "skill/SKILL.md is ${LINE_COUNT} lines (>= 300 limit)"
  fi
fi

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "================================================"
PASSED=$((TOTAL - FAILURES - WARNINGS))
echo "  ${PASSED} passed, ${FAILURES} failed, ${WARNINGS} warnings (${TOTAL} checks)"

if [[ "$FAILURES" -gt 0 ]]; then
  echo "  RESULT: FAIL"
  echo ""
  exit 1
else
  echo "  RESULT: PASS"
  echo ""
  exit 0
fi
