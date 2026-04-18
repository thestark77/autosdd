# autoSDD Installer — installs gentle-ai + autoSDD skill
# Windows PowerShell. For macOS/Linux, use install.sh

# Wrap in scriptblock so exit doesn't kill the terminal when run via irm | iex
& {

$ErrorActionPreference = "Stop"

$REPO_URL = "https://raw.githubusercontent.com/thestark77/autosdd/main"
$SKILL_URL = "$REPO_URL/skill/SKILL.md"

$AGENTS = @(
  "claude-code",
  "opencode",
  "kilocode",
  "gemini-cli",
  "cursor",
  "vscode-copilot",
  "codex",
  "antigravity",
  "windsurf",
  "kimi",
  "qwen-code",
  "kiro-ide"
)

$AGENT_DIRS = @(
  "$env:USERPROFILE\.claude",
  "$env:USERPROFILE\.config\opencode",
  "$env:USERPROFILE\.config\kilo",
  "$env:USERPROFILE\.gemini",
  "$env:USERPROFILE\.cursor",
  "$env:USERPROFILE\.copilot",
  "$env:USERPROFILE\.codex",
  "$env:USERPROFILE\.gemini\antigravity",
  "$env:USERPROFILE\.codeium\windsurf",
  "$env:USERPROFILE\.kimi",
  "$env:USERPROFILE\.qwen",
  "$env:USERPROFILE\.kiro"
)

Write-Host ""
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host "  |     autoSDD v3 - Installer               |" -ForegroundColor Cyan
Write-Host "  |     Self-Improving Autonomous Dev         |" -ForegroundColor Cyan
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Agent Selection ---
Write-Host "Step 1/2 - Select AI agents to configure" -ForegroundColor Yellow
Write-Host "  (ENTER = all agents)"
Write-Host ""
for ($i = 0; $i -lt $AGENTS.Count; $i++) {
  Write-Host ("  {0,2}. {1}" -f ($i + 1), $AGENTS[$i])
}
Write-Host ""
$agentInput = Read-Host "  Agents (comma-separated numbers, e.g. 1,3,5)"

$selectedAgents = @()
if ([string]::IsNullOrWhiteSpace($agentInput)) {
  $selectedAgents = $AGENTS
  Write-Host "  -> All agents selected"
} else {
  $nums = $agentInput -split ',' | ForEach-Object { $_.Trim() }
  foreach ($n in $nums) {
    $idx = [int]$n - 1
    if ($idx -ge 0 -and $idx -lt $AGENTS.Count) {
      $selectedAgents += $AGENTS[$idx]
    }
  }
  Write-Host "  -> Selected: $($selectedAgents -join ', ')"
}
Write-Host ""

# --- Step 2: Persona Selection ---
Write-Host "Step 2/2 - Select AI response style" -ForegroundColor Yellow
Write-Host "  (ENTER = neutral)"
Write-Host ""
Write-Host "  1. gentleman  - Rioplatense Spanish, passionate, opinionated"
Write-Host "  2. neutral     - Professional, no regional style"
Write-Host "  3. custom      - Define your own"
Write-Host ""
$personaInput = Read-Host "  Persona (1/2/3)"

$selectedPersona = "neutral"
switch ($personaInput) {
  "1" { $selectedPersona = "gentleman" }
  "2" { $selectedPersona = "neutral" }
  "3" { $selectedPersona = "custom" }
  default { $selectedPersona = "neutral" }
}
Write-Host "  -> Selected: $selectedPersona"
Write-Host ""

# --- Check prerequisites ---
Write-Host "Checking prerequisites..."

# Check Scoop
$scoop = Get-Command scoop -ErrorAction SilentlyContinue
if (-not $scoop) {
  Write-Host ""
  Write-Host "  ! Scoop is required to install dependencies on Windows." -ForegroundColor Red
  Write-Host ""
  Write-Host "  Install Scoop first:" -ForegroundColor Yellow
  Write-Host "    https://scoop.sh"
  Write-Host ""
  Write-Host "  Then run this installer again."
  Write-Host ""
  return
}
Write-Host "  OK scoop"

# Check Go (required by engram, installed by gentle-ai)
$goCmd = Get-Command go -ErrorAction SilentlyContinue
if (-not $goCmd) {
  Write-Host "  . Go not found - installing via scoop..." -ForegroundColor Yellow
  & scoop install go
  $goCmd = Get-Command go -ErrorAction SilentlyContinue
  if (-not $goCmd) {
    Write-Host "  ! Go installation failed." -ForegroundColor Red
    Write-Host "  Install manually: https://go.dev/dl/" -ForegroundColor Yellow
    Write-Host ""
    return
  }
}
Write-Host "  OK go"

# Ensure GOBIN is in PATH (engram binary lands here)
$gobin = & go env GOBIN 2>$null
if ([string]::IsNullOrWhiteSpace($gobin)) {
  $gobin = Join-Path (& go env GOPATH 2>$null) "bin"
}
if ($gobin -and -not ($env:Path -like "*$gobin*")) {
  $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if ($currentPath -notlike "*$gobin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$gobin", "User")
  }
  $env:Path = "$env:Path;$gobin"
  Write-Host "  OK added $gobin to PATH"
}

# Check gentle-ai
$gentleAi = Get-Command gentle-ai -ErrorAction SilentlyContinue
if (-not $gentleAi) {
  Write-Host "  . gentle-ai not found - installing via scoop..." -ForegroundColor Yellow
  & scoop bucket add gentleman https://github.com/Gentleman-Programming/scoop-bucket 2>$null
  & scoop install gentle-ai

  $gentleAi = Get-Command gentle-ai -ErrorAction SilentlyContinue
  if (-not $gentleAi) {
    Write-Host ""
    Write-Host "  ! gentle-ai installation failed." -ForegroundColor Red
    Write-Host "  Try manually: scoop install gentle-ai"
    Write-Host "  Docs: https://github.com/Gentleman-Programming/gentle-ai#installation"
    Write-Host ""
    return
  }
}
Write-Host "  OK gentle-ai"

Write-Host ""

# --- Install gentle-ai ---
Write-Host "Installing gentle-ai..."
Write-Host "  Agents:   $($selectedAgents -join ',')"
Write-Host "  Persona:  $selectedPersona"
Write-Host "  Preset:   full-gentleman"
Write-Host "  SDD Mode: multi"
Write-Host ""

$agentsCsv = $selectedAgents -join ','
& gentle-ai install `
  --agents $agentsCsv `
  --persona $selectedPersona `
  --preset full-gentleman `
  --sdd-mode multi

if ($LASTEXITCODE -ne 0) {
  Write-Host "  ! gentle-ai install failed (exit code $LASTEXITCODE)" -ForegroundColor Red
  Write-Host "  Check the output above for details." -ForegroundColor Yellow
  return
}

Write-Host ""
Write-Host "  OK gentle-ai installed" -ForegroundColor Green

# --- Configure OpenCode profiles (if opencode was selected) ---
if ($selectedAgents -contains "opencode") {
  Write-Host ""
  Write-Host "Configuring OpenCode SDD profiles..."
  try {
    & gentle-ai sync `
      --agents opencode `
      --profile "autosdd:openrouter/anthropic/claude-opus-4-6" `
      --profile-phase "autosdd:sdd-init:openrouter/anthropic/claude-sonnet-4-6" `
      --profile-phase "autosdd:sdd-explore:openrouter/anthropic/claude-sonnet-4-6" `
      --profile-phase "autosdd:sdd-propose:openrouter/google/gemini-2.5-pro-preview" `
      --profile-phase "autosdd:sdd-spec:openrouter/google/gemini-2.5-pro-preview" `
      --profile-phase "autosdd:sdd-design:openrouter/anthropic/claude-opus-4-6" `
      --profile-phase "autosdd:sdd-tasks:openrouter/openai/gpt-5.4" `
      --profile-phase "autosdd:sdd-apply:openrouter/anthropic/claude-sonnet-4-6" `
      --profile-phase "autosdd:sdd-verify:openrouter/openai/gpt-5.4" `
      --profile-phase "autosdd:sdd-archive:openrouter/anthropic/claude-sonnet-4-6"
    Write-Host "  OK OpenCode profiles configured" -ForegroundColor Green
  } catch {
    Write-Host "  ! OpenCode profile config skipped (OpenCode may not be installed)" -ForegroundColor Yellow
  }
}

# --- Install autoSDD SKILL.md ---
Write-Host ""
Write-Host "Installing autoSDD skill..."

for ($i = 0; $i -lt $AGENTS.Count; $i++) {
  $agent = $AGENTS[$i]
  if ($selectedAgents -contains $agent) {
    $skillDir = Join-Path $AGENT_DIRS[$i] "skills\autosdd"
    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
    $skillFile = Join-Path $skillDir "SKILL.md"
    Invoke-WebRequest -Uri $SKILL_URL -OutFile $skillFile -UseBasicParsing
    Write-Host "  OK $agent -> $skillFile"
  }
}

# --- Install RTK (Rust Token Killer) ---
Write-Host ""
Write-Host "Installing RTK (token optimization)..."

$rtkCmd = Get-Command rtk -ErrorAction SilentlyContinue
if ($rtkCmd) {
  Write-Host "  OK RTK already installed"
} else {
  $cargoCmd = Get-Command cargo -ErrorAction SilentlyContinue
  if ($cargoCmd) {
    Write-Host "  Installing via cargo..."
    & cargo install rtk
    Write-Host "  OK RTK installed via cargo"
  } else {
    Write-Host "  Downloading RTK from GitHub releases..."
    $rtkDir = Join-Path $env:USERPROFILE ".local\bin"
    New-Item -ItemType Directory -Path $rtkDir -Force | Out-Null

    $rtkRelease = "https://github.com/rtk-ai/rtk/releases/latest/download/rtk-x86_64-pc-windows-msvc.zip"
    $rtkZip = Join-Path $env:TEMP "rtk.zip"
    try {
      Invoke-WebRequest -Uri $rtkRelease -OutFile $rtkZip -UseBasicParsing
      Expand-Archive -Path $rtkZip -DestinationPath $rtkDir -Force
      Remove-Item $rtkZip -Force

      # Add to PATH if not already there
      $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
      if ($currentPath -notlike "*$rtkDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$rtkDir", "User")
        $env:Path = "$env:Path;$rtkDir"
      }
      Write-Host "  OK RTK installed to $rtkDir"
    } catch {
      Write-Host "  ! RTK auto-install failed. Install manually:" -ForegroundColor Yellow
      Write-Host "    cargo install rtk"
      Write-Host "    OR download from: https://github.com/rtk-ai/rtk/releases"
    }
  }
}

# --- Verify prompt-engineering-patterns ---
Write-Host ""
Write-Host "Verifying prompt-engineering-patterns skill..."

$pepFound = $false
for ($i = 0; $i -lt $AGENTS.Count; $i++) {
  $agent = $AGENTS[$i]
  if ($selectedAgents -contains $agent) {
    $pepFile = Join-Path $AGENT_DIRS[$i] "skills\prompt-engineering-patterns\SKILL.md"
    if (Test-Path $pepFile) {
      $pepFound = $true
      break
    }
  }
}

if ($pepFound) {
  Write-Host "  OK prompt-engineering-patterns found (installed by gentle-ai)"
} else {
  Write-Host "  ! prompt-engineering-patterns not found." -ForegroundColor Yellow
  Write-Host "    This skill is CORE to autoSDD (used with CREA on ALL prompts)."
  Write-Host "    It should be installed by gentle-ai --preset full-gentleman."
  Write-Host "    Run: gentle-ai sync --skills prompt-engineering-patterns"
}

# --- Bootstrap project templates ---
Write-Host ""
Write-Host "Bootstrapping project templates..."

$TEMPLATE_URL = "$REPO_URL/templates"
$contextDir = Join-Path (Get-Location) "context"

if (Test-Path $contextDir) {
  Write-Host "  context/ directory already exists - skipping existing files"
}

New-Item -ItemType Directory -Path $contextDir -Force | Out-Null

$templates = @("guidelines.md", "user_context.md", "business_logic.md", "autosdd.md")
foreach ($tmpl in $templates) {
  $target = Join-Path $contextDir $tmpl
  if (Test-Path $target) {
    Write-Host "  . $tmpl already exists - skipped"
  } else {
    Invoke-WebRequest -Uri "$TEMPLATE_URL/$tmpl" -OutFile $target -UseBasicParsing
    Write-Host "  OK $tmpl -> $target"
  }
}

# --- Inject autoSDD block into CLAUDE.md ---
$AUTOSDD_BLOCK = @"
<!-- autosdd:start -->
## autoSDD — Active Framework (DO NOT REMOVE)

autoSDD v3 is the ACTIVE development framework for this project.
ALL prompts go through autoSDD unless the user explicitly opts out.

### Default Behavior
- Every prompt -> Flow Router -> CREA Prompt Refine -> Execute Flow -> Outcome Collection
- CREA framework (Context, Role, Specificity, Action) + prompt-engineering-patterns on ALL prompt creation
- 5 flows: Development, Code Review, Debugging, Research, Self-Improvement
- Orchestrator delegates to sub-agents, NEVER executes directly
- Monitor tool for ALL waiting/watching (NEVER poll)
- RTK prefix on ALL shell commands

### Three Critical Context Files (sacred, auto-updated)
- ``context/guidelines.md`` — Technical rules and conventions
- ``context/user_context.md`` — User profile and preferences
- ``context/business_logic.md`` — Domain knowledge and workflows

### Opt-Out
- ``[raw]`` prefix: skip framework entirely
- ``[no-sdd]`` prefix: skip SDD but keep CREA
- ``skip autosdd``: natural language opt-out

Read the autoSDD skill: ``~/.claude/skills/autosdd/SKILL.md``
<!-- autosdd:end -->
"@

$claudeMd = Join-Path (Get-Location) "CLAUDE.md"
if (-not (Test-Path $claudeMd)) {
  Invoke-WebRequest -Uri "$TEMPLATE_URL/CLAUDE.md" -OutFile $claudeMd -UseBasicParsing
  Write-Host "  OK CLAUDE.md -> $claudeMd (full template)"
} elseif ((Get-Content $claudeMd -Raw) -match "autosdd:start") {
  $content = Get-Content $claudeMd -Raw
  $content = $content -replace "(?s)<!-- autosdd:start -->.*?<!-- autosdd:end -->", $AUTOSDD_BLOCK
  Set-Content -Path $claudeMd -Value $content -NoNewline
  Write-Host "  OK CLAUDE.md -> autoSDD block updated (markers replaced)"
} else {
  Add-Content -Path $claudeMd -Value "`n$AUTOSDD_BLOCK"
  Write-Host "  OK CLAUDE.md -> autoSDD block injected (appended)"
}

# --- Done ---
Write-Host ""
Write-Host "  +==========================================+" -ForegroundColor Green
Write-Host "  |     autoSDD v3 installed!                 |" -ForegroundColor Green
Write-Host "  +==========================================+" -ForegroundColor Green
Write-Host ""
Write-Host "  What was installed:"
Write-Host "    OK gentle-ai (SDD skills, Engram memory, agent config)"
Write-Host "    OK autoSDD skill (methodology layer)"
Write-Host "    OK RTK (token optimization - 60-90% savings)"
Write-Host "    OK Project templates (context/ + CLAUDE.md)"
Write-Host ""
Write-Host "  Next steps:"
Write-Host "    1. Open your project in your AI agent"
Write-Host "    2. Run /sdd-init to bootstrap the project"
Write-Host "    3. Run /sdd-new <feature> to start building"
Write-Host ""
Write-Host "  Update autoSDD later:"
Write-Host "    irm $REPO_URL/install.ps1 | iex"
Write-Host ""
Write-Host "  Docs: https://github.com/thestark77/autosdd"
Write-Host ""

}
