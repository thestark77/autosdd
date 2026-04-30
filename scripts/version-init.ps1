# autoSDD automation script — managed by installer
# version-init.ps1 — Mechanical VERSION INIT for pipeline Step 0
#
# Usage:
#   version-init.ps1 [VERSION]
#
# If VERSION is omitted, reads PROGRESS.md and increments the latest patch number.
# Outputs the version string (e.g. "6.0.1") to stdout on success.
#
# Environment:
#   PROJECT_ROOT  Override project root (default: script's grandparent directory)

param(
    [Parameter(Position = 0)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

# ── Resolve project root ─────────────────────────────────────────────────────

if ($env:PROJECT_ROOT) {
    $Root = $env:PROJECT_ROOT
} else {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $Root = Split-Path -Parent $ScriptDir
}

$ProgressFile = Join-Path $Root "PROGRESS.md"
$VersionsDir = Join-Path $Root "context" "appVersions"

# ── Determine version ────────────────────────────────────────────────────────

if (-not $Version) {
    # Auto-increment: find latest v line in PROGRESS.md
    if (-not (Test-Path $ProgressFile)) {
        Write-Error "PROGRESS.md not found at $ProgressFile and no version argument provided"
        exit 1
    }

    $Content = Get-Content $ProgressFile -Raw
    $Match = [regex]::Match($Content, 'v(\d+)\.(\d+)\.(\d+)')

    if (-not $Match.Success) {
        Write-Error "No version pattern (vX.Y.Z) found in PROGRESS.md"
        exit 1
    }

    $Major = [int]$Match.Groups[1].Value
    $Minor = [int]$Match.Groups[2].Value
    $Patch = [int]$Match.Groups[3].Value + 1
    $Version = "$Major.$Minor.$Patch"
}

# Validate version format
if ($Version -notmatch '^\d+\.\d+\.\d+$') {
    Write-Error "Invalid version format '$Version'. Expected X.Y.Z"
    exit 1
}

# ── Create version directory ─────────────────────────────────────────────────

$VersionDir = Join-Path $VersionsDir "v$Version"
if (-not (Test-Path $VersionDir)) {
    New-Item -ItemType Directory -Path $VersionDir -Force | Out-Null
}

# ── Reset PROGRESS.md ────────────────────────────────────────────────────────

$ProgressContent = @"
# PROGRESS

## v$Version — STARTED
"@

Set-Content -Path $ProgressFile -Value $ProgressContent -Encoding UTF8 -NoNewline

# ── Output version ───────────────────────────────────────────────────────────

Write-Output $Version
exit 0
