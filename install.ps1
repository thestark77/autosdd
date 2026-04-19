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
Write-Host "  |     Self-Improving Autonomous Dev        |" -ForegroundColor Cyan
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

# Check Node.js (required by Context7 MCP and npx commands)
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
  Write-Host "  . Node.js not found - installing via scoop..." -ForegroundColor Yellow
  & scoop install nodejs
  $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
  if (-not $nodeCmd) {
    Write-Host "  ! Node.js installation failed." -ForegroundColor Red
    Write-Host "  Install manually: https://nodejs.org/en/download" -ForegroundColor Yellow
    Write-Host ""
    return
  }
}
Write-Host "  OK node $(node --version 2>$null)"

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

# --- Stop running engram process (Windows locks running executables) ---
$engramProc = Get-Process -Name "engram" -ErrorAction SilentlyContinue
if ($engramProc) {
  Write-Host "  . Stopping running engram process (required to update binary)..." -ForegroundColor Yellow
  Stop-Process -Name "engram" -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 1
  Write-Host "  OK engram process stopped"
}

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
  Write-Host "  . gentle-ai exited with code $LASTEXITCODE (verification warnings)" -ForegroundColor Yellow
  Write-Host "  This usually means installation completed with non-critical issues."
  Write-Host "  Continuing with the rest of the setup..."
  Write-Host ""
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

# --- Install core skills globally ---
Write-Host ""
Write-Host "Installing core skills (global)..."

$warnings = @()
$installedSkillPaths = @()

# 1. Install autoSDD skill directly (from this repo)
for ($i = 0; $i -lt $AGENTS.Count; $i++) {
  $agent = $AGENTS[$i]
  if ($selectedAgents -contains $agent) {
    $skillDir = Join-Path $AGENT_DIRS[$i] "skills\autosdd"
    try {
      New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
      $skillFile = Join-Path $skillDir "SKILL.md"
      Invoke-WebRequest -Uri "$REPO_URL/skill/SKILL.md" -OutFile $skillFile -UseBasicParsing
      $installedSkillPaths += $skillFile
      Write-Host "  OK autosdd ($agent)"
    } catch {
      $msg = "Failed to install autosdd for $agent — $_"
      Write-Host "  ! $msg" -ForegroundColor Red
      $warnings += $msg
    }
  }
}

# 2. Install remaining core skills via skills.sh (canonical sources)
$SKILLS_SH = @(
  @{ repo = "https://github.com/wshobson/agents"; skill = "prompt-engineering-patterns" },
  @{ repo = "https://github.com/gentleman-programming/sdd-agent-team"; skill = "branch-pr" },
  @{ repo = "https://github.com/gentleman-programming/sdd-agent-team"; skill = "judgment-day" },
  @{ repo = "https://github.com/anthropics/skills"; skill = "frontend-design" },
  @{ repo = "https://github.com/dammyjay93/interface-design"; skill = "interface-design" },
  @{ repo = "https://github.com/anthropics/claude-plugins-official"; skill = "claude-md-improver" },
  @{ repo = "https://github.com/wshobson/agents"; skill = "e2e-testing-patterns" },
  @{ repo = "https://github.com/wshobson/agents"; skill = "error-handling-patterns" },
  @{ repo = "https://github.com/microsoft/playwright-cli"; skill = "playwright-cli" }
)

foreach ($entry in $SKILLS_SH) {
  Write-Host "  . Installing $($entry.skill)..."
  try {
    & npx -y skills add $entry.repo --skill $entry.skill -g -y 2>$null
    if ($LASTEXITCODE -ne 0) { throw "npx skills exited with code $LASTEXITCODE" }
    Write-Host "  OK $($entry.skill)"
  } catch {
    $msg = "Failed to install $($entry.skill) via skills.sh — $_"
    Write-Host "  ! $msg" -ForegroundColor Yellow
    $warnings += $msg
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
    try {
      Invoke-WebRequest -Uri "$TEMPLATE_URL/$tmpl" -OutFile $target -UseBasicParsing
      Write-Host "  OK $tmpl -> $target"
    } catch {
      Write-Host "  ! Failed to download $tmpl" -ForegroundColor Yellow
    }
  }
}

# --- Inject autoSDD block into CLAUDE.md ---

# Build skill path references for all selected agents
$skillPathRefs = ($installedSkillPaths | ForEach-Object { "- ``$_``" }) -join "`n"

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

Read the full framework: ``context/autosdd.md``
autoSDD skill installed at:
$skillPathRefs
<!-- autosdd:end -->
"@

$claudeMd = Join-Path (Get-Location) "CLAUDE.md"
if (-not (Test-Path $claudeMd)) {
  try {
    Invoke-WebRequest -Uri "$TEMPLATE_URL/CLAUDE.md" -OutFile $claudeMd -UseBasicParsing
    Write-Host "  OK CLAUDE.md -> $claudeMd (full template)"
  } catch {
    Write-Host "  ! Failed to download CLAUDE.md template" -ForegroundColor Yellow
  }
}

# Inject or update autoSDD block (even in freshly downloaded template)
if (Test-Path $claudeMd) {
  $content = Get-Content $claudeMd -Raw
  if ($content -match "autosdd:start") {
    $content = $content -replace "(?s)<!-- autosdd:start -->.*?<!-- autosdd:end -->", $AUTOSDD_BLOCK
    Set-Content -Path $claudeMd -Value $content -NoNewline
    Write-Host "  OK CLAUDE.md -> autoSDD block updated (markers replaced)"
  } else {
    Add-Content -Path $claudeMd -Value "`n$AUTOSDD_BLOCK"
    Write-Host "  OK CLAUDE.md -> autoSDD block injected (appended)"
  }
}

# --- Final Verification ---
Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Yellow
Write-Host ""

$allGood = $true

# Check gentle-ai
if (Get-Command gentle-ai -ErrorAction SilentlyContinue) {
  Write-Host "  [OK] gentle-ai" -ForegroundColor Green
} else {
  Write-Host "  [!!] gentle-ai NOT found" -ForegroundColor Red
  $allGood = $false
}

# Check engram
$engramCmd = Get-Command engram -ErrorAction SilentlyContinue
if ($engramCmd) {
  Write-Host "  [OK] engram MCP" -ForegroundColor Green
} else {
  Write-Host "  [!!] engram NOT in PATH — restart your terminal" -ForegroundColor Yellow
}

# Check RTK
if (Get-Command rtk -ErrorAction SilentlyContinue) {
  Write-Host "  [OK] RTK" -ForegroundColor Green
} else {
  Write-Host "  [..] RTK not in PATH — restart terminal or install: cargo install rtk" -ForegroundColor Yellow
}

# Check autoSDD skill for each selected agent
foreach ($path in $installedSkillPaths) {
  if (Test-Path $path) {
    Write-Host "  [OK] $path" -ForegroundColor Green
  } else {
    Write-Host "  [!!] MISSING: $path" -ForegroundColor Red
    $allGood = $false
  }
}

# Check SDD skills (from gentle-ai)
$sddSkills = @("sdd-init", "sdd-explore", "sdd-propose", "sdd-spec", "sdd-design", "sdd-tasks", "sdd-apply", "sdd-verify", "sdd-archive")
for ($i = 0; $i -lt $AGENTS.Count; $i++) {
  $agent = $AGENTS[$i]
  if ($selectedAgents -contains $agent) {
    $missingSkills = @()
    foreach ($skill in $sddSkills) {
      $spath = Join-Path $AGENT_DIRS[$i] "skills\$skill\SKILL.md"
      if (-not (Test-Path $spath)) { $missingSkills += $skill }
    }
    if ($missingSkills.Count -eq 0) {
      Write-Host "  [OK] SDD skills ($agent) — all 9 installed" -ForegroundColor Green
    } else {
      Write-Host "  [!!] SDD skills ($agent) — MISSING: $($missingSkills -join ', ')" -ForegroundColor Red
      $allGood = $false
    }

    # Check core skills installed by autoSDD
    $coreSkillNames = @("autosdd") + ($SKILLS_SH | ForEach-Object { $_.skill })
    foreach ($cs in $coreSkillNames) {
      $csPath = Join-Path $AGENT_DIRS[$i] "skills\$cs\SKILL.md"
      if (Test-Path $csPath) {
        Write-Host "  [OK] $cs ($agent)" -ForegroundColor Green
      } else {
        Write-Host "  [!!] $cs MISSING ($agent)" -ForegroundColor Red
        $warnings += "$cs skill not found at $csPath"
        $allGood = $false
      }
    }
    break
  }
}

# Check project templates
$contextDir = Join-Path (Get-Location) "context"
if (Test-Path (Join-Path $contextDir "autosdd.md")) {
  Write-Host "  [OK] Project templates (context/)" -ForegroundColor Green
} else {
  Write-Host "  [!!] Project templates missing" -ForegroundColor Red
  $allGood = $false
}

# Check CLAUDE.md injection
$claudeMd = Join-Path (Get-Location) "CLAUDE.md"
if ((Test-Path $claudeMd) -and ((Get-Content $claudeMd -Raw) -match "autosdd:start")) {
  Write-Host "  [OK] CLAUDE.md autoSDD block" -ForegroundColor Green
} else {
  Write-Host "  [!!] CLAUDE.md autoSDD block missing" -ForegroundColor Red
  $allGood = $false
}

# --- Done ---
Write-Host ""
if ($allGood) {
  Write-Host "  +==========================================+" -ForegroundColor Green
  Write-Host "  |     autoSDD v3 installed!                |" -ForegroundColor Green
  Write-Host "  +==========================================+" -ForegroundColor Green
} else {
  Write-Host "  +==========================================+" -ForegroundColor Yellow
  Write-Host "  |  autoSDD v3 installed (with warnings)    |" -ForegroundColor Yellow
  Write-Host "  +==========================================+" -ForegroundColor Yellow
}

# Show collected warnings/errors
if ($warnings.Count -gt 0) {
  Write-Host ""
  Write-Host "  Warnings/Errors during installation:" -ForegroundColor Yellow
  Write-Host "  ------------------------------------" -ForegroundColor Yellow
  foreach ($w in $warnings) {
    Write-Host "  - $w" -ForegroundColor Yellow
  }
  Write-Host ""
  Write-Host "  If re-running the installer doesn't fix these:" -ForegroundColor Cyan
  Write-Host "    Report:  https://github.com/thestark77/autosdd/issues/new" -ForegroundColor Cyan
  Write-Host "    Fix it:  https://github.com/thestark77/autosdd/pulls" -ForegroundColor Cyan
  Write-Host ""
}

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
