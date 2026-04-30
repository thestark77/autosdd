# autoSDD automation script — managed by installer
# version-lint.ps1 — Verify sync paths at version close (Step 6/7)
#
# Usage:
#   version-lint.ps1 VERSION
#
# Checks version strings across all sync-path files and reports PASS/FAIL.
# Exit 0 if all pass, exit 1 if any fail.
#
# Environment:
#   PROJECT_ROOT  Override project root (default: script's grandparent directory)

param(
    [Parameter(Mandatory = $true, Position = 0)]
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

# ── Validate arguments ───────────────────────────────────────────────────────

if ($Version -notmatch '^\d+\.\d+\.\d+$') {
    Write-Error "Invalid version format '$Version'. Expected X.Y.Z"
    exit 1
}

# Major.Minor for block version strings (e.g. "autoSDD v6.0")
$MajorMinor = ($Version -split '\.')[0..1] -join '.'

# ── Check helpers ────────────────────────────────────────────────────────────

$Failures = 0
$Warnings = 0
$Total = 0

function Pass($Message) {
    $script:Total++
    Write-Host "  PASS  $Message" -ForegroundColor Green
}

function Fail($Message) {
    $script:Total++
    $script:Failures++
    Write-Host "  FAIL  $Message" -ForegroundColor Red
}

function Warn($Message) {
    $script:Total++
    $script:Warnings++
    Write-Host "  WARN  $Message" -ForegroundColor Yellow
}

# ── Checks ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "autoSDD version-lint - checking v$Version"
Write-Host "================================================"
Write-Host ""

# 1. SKILL.md frontmatter version
$SkillFile = Join-Path $Root "skill" "SKILL.md"
if (Test-Path $SkillFile) {
    $SkillContent = Get-Content $SkillFile -Raw
    if ($SkillContent -match "version:\s*`"$([regex]::Escape($Version))`"") {
        Pass "skill/SKILL.md contains version: `"$Version`""
    } else {
        Fail "skill/SKILL.md does NOT contain version: `"$Version`""
    }
} else {
    Fail "skill/SKILL.md not found"
}

# 2. templates/CLAUDE.md autoSDD block version
$TemplateFile = Join-Path $Root "templates" "CLAUDE.md"
if (Test-Path $TemplateFile) {
    $TemplateContent = Get-Content $TemplateFile -Raw
    if ($TemplateContent.Contains("autoSDD v$MajorMinor")) {
        Pass "templates/CLAUDE.md contains autoSDD v$MajorMinor"
    } else {
        Fail "templates/CLAUDE.md does NOT contain autoSDD v$MajorMinor"
    }
} else {
    Fail "templates/CLAUDE.md not found"
}

# 3. install.sh AUTOSDD_BLOCK version
$InstallSh = Join-Path $Root "install.sh"
if (Test-Path $InstallSh) {
    $InstallShContent = Get-Content $InstallSh -Raw
    if ($InstallShContent.Contains("autoSDD v$MajorMinor")) {
        Pass "install.sh contains autoSDD v$MajorMinor"
    } else {
        Fail "install.sh does NOT contain autoSDD v$MajorMinor"
    }
} else {
    Fail "install.sh not found"
}

# 4. install.ps1 AUTOSDD_BLOCK version
$InstallPs1 = Join-Path $Root "install.ps1"
if (Test-Path $InstallPs1) {
    $InstallPs1Content = Get-Content $InstallPs1 -Raw
    if ($InstallPs1Content.Contains("autoSDD v$MajorMinor")) {
        Pass "install.ps1 contains autoSDD v$MajorMinor"
    } else {
        Fail "install.ps1 does NOT contain autoSDD v$MajorMinor"
    }
} else {
    Fail "install.ps1 not found"
}

# 5. Version directory exists
$VersionDir = Join-Path $Root "context" "appVersions" "v$Version"
if (Test-Path $VersionDir -PathType Container) {
    Pass "context/appVersions/v$Version/ exists"
} else {
    Fail "context/appVersions/v$Version/ does NOT exist"
}

# 6. feedback.md exists (warn only)
$FeedbackFile = Join-Path $VersionDir "feedback.md"
if (Test-Path $FeedbackFile) {
    Pass "context/appVersions/v$Version/feedback.md exists"
} else {
    Warn "context/appVersions/v$Version/feedback.md is missing (not a hard failure)"
}

# 7. SKILL.md under 300 lines
if (Test-Path $SkillFile) {
    $LineCount = (Get-Content $SkillFile).Count
    if ($LineCount -lt 300) {
        Pass "skill/SKILL.md is $LineCount lines (< 300 limit)"
    } else {
        Fail "skill/SKILL.md is $LineCount lines (>= 300 limit)"
    }
}

# ── Summary ──────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "================================================"
$Passed = $Total - $Failures - $Warnings
Write-Host "  $Passed passed, $Failures failed, $Warnings warnings ($Total checks)"

if ($Failures -gt 0) {
    Write-Host "  RESULT: FAIL" -ForegroundColor Red
    Write-Host ""
    exit 1
} else {
    Write-Host "  RESULT: PASS" -ForegroundColor Green
    Write-Host ""
    exit 0
}
