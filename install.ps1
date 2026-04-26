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

# Warning collector — populated throughout the install for the final report.
$warnings = @()

# --- Embedding backend configuration ---
# Curated list of OpenAI-compatible embedding providers.
# Models chosen for quality/cost balance (<=$0.10/1M tokens) with multilingual support.
# Index 0 = local (Ollama); indexes 1-5 = remote API providers.
$EMBED_PROVIDERS = @(
  @{ Name = "local";      Url = "";                                                 Model = "bge-m3" }
  @{ Name = "OpenAI";     Url = "https://api.openai.com/v1/embeddings";             Model = "text-embedding-3-small" }
  @{ Name = "OpenRouter"; Url = "https://openrouter.ai/api/v1/embeddings";          Model = "openai/text-embedding-3-small" }
  @{ Name = "Voyage AI";  Url = "https://api.voyageai.com/v1/embeddings";           Model = "voyage-3" }
  @{ Name = "Mistral";    Url = "https://api.mistral.ai/v1/embeddings";             Model = "mistral-embed" }
  @{ Name = "Jina AI";    Url = "https://api.jina.ai/v1/embeddings";                Model = "jina-embeddings-v3" }
)

$OLLAMA_LOCAL_URL   = "http://localhost:11434/v1/embeddings"
$OLLAMA_LOCAL_MODEL = "bge-m3"

$ENGRAM_STATE_DIR = "$env:USERPROFILE\.engram"
$KEYCHAIN_SERVICE = "engram-embedding"

# --- Helper: validate an API key by issuing a real embed request ---
function Test-EmbeddingApiKey {
  param([string]$Url, [string]$Model, [string]$Key)
  try {
    $body = @{ model = $Model; input = @("hello") } | ConvertTo-Json -Compress
    $resp = Invoke-WebRequest -Uri $Url -Method POST `
      -Headers @{ "Authorization" = "Bearer $Key"; "Content-Type" = "application/json" } `
      -Body $body -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    return $resp.StatusCode -eq 200
  } catch {
    return $false
  }
}

# --- Helper: store API key via Windows DPAPI (encrypted at rest with user account) ---
# Returns the friendly storage method name.
function Save-ApiKeySecure {
  param([string]$Key)
  New-Item -ItemType Directory -Path $ENGRAM_STATE_DIR -Force | Out-Null
  $secure    = ConvertTo-SecureString -String $Key -AsPlainText -Force
  $encrypted = $secure | ConvertFrom-SecureString
  $path      = Join-Path $ENGRAM_STATE_DIR "api-key.dpapi"
  Set-Content -Path $path -Value $encrypted -NoNewline
  # Restrict ACL to current user only
  try {
    $acl = Get-Acl $path
    $acl.SetAccessRuleProtection($true, $false)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
      $env:USERNAME, "FullControl", "Allow"
    )
    $acl.AddAccessRule($rule)
    Set-Acl $path $acl
  } catch { }
  return "Windows DPAPI ($($path | Split-Path -Leaf), user-scoped)"
}

# --- Helper: detect existing local (Ollama) install ---
function Test-LocalInstalled {
  if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) { return $false }
  $list = & ollama list 2>$null
  return ($list -match "^$OLLAMA_LOCAL_MODEL(\s|:)")
}

# --- Helper: detect existing api configuration ---
function Test-ApiConfigured {
  $urlFile   = Join-Path $ENGRAM_STATE_DIR "api-url"
  $modelFile = Join-Path $ENGRAM_STATE_DIR "api-model"
  $keyFile   = Join-Path $ENGRAM_STATE_DIR "api-key.dpapi"
  return (Test-Path $urlFile) -and (Test-Path $modelFile) -and (Test-Path $keyFile)
}

# --- Helper: confirm re-install of same mode (interactive) ---
function Confirm-Reinstall {
  param([string]$Label)
  Write-Host ""
  Write-Host "  ! A $Label embedding configuration is already present." -ForegroundColor Yellow
  Write-Host "    Re-installing will ERASE the existing $Label setup and reconfigure from scratch."
  Write-Host ""
  $ans = Read-Host "  Proceed with re-install? [y/N]"
  return ($ans -match "^[Yy]$")
}

Write-Host ""
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host "  |     autoSDD v3 - Installer               |" -ForegroundColor Cyan
Write-Host "  |     Self-Improving Autonomous Dev        |" -ForegroundColor Cyan
Write-Host "  +==========================================+" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Agent Selection ---
Write-Host "Step 1/3 - Select AI agents to configure" -ForegroundColor Yellow
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
Write-Host "Step 2/3 - Select AI response style" -ForegroundColor Yellow
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

# --- Step 3: Semantic search backend ---
Write-Host "Step 3/3 - Semantic search backend for Engram" -ForegroundColor Yellow
Write-Host "  (ENTER = local [default], 100% offline, no API key needed)"
Write-Host ""
Write-Host "  1. local        Ollama + bge-m3  (~2.3GB, free, offline)  [default]"
Write-Host ("  2. OpenAI       ({0})" -f $EMBED_PROVIDERS[1].Model)
Write-Host ("  3. OpenRouter   ({0})" -f $EMBED_PROVIDERS[2].Model)
Write-Host ("  4. Voyage AI    ({0})" -f $EMBED_PROVIDERS[3].Model)
Write-Host ("  5. Mistral      ({0})" -f $EMBED_PROVIDERS[4].Model)
Write-Host ("  6. Jina AI      ({0})" -f $EMBED_PROVIDERS[5].Model)
Write-Host ""
$embedInput = Read-Host "  Backend (1-6)"

$embeddingMode = "local"
$embedIdx = 0
switch ($embedInput) {
  ""  { $embeddingMode = "local"; $embedIdx = 0 }
  "1" { $embeddingMode = "local"; $embedIdx = 0 }
  "2" { $embeddingMode = "api";   $embedIdx = 1 }
  "3" { $embeddingMode = "api";   $embedIdx = 2 }
  "4" { $embeddingMode = "api";   $embedIdx = 3 }
  "5" { $embeddingMode = "api";   $embedIdx = 4 }
  "6" { $embeddingMode = "api";   $embedIdx = 5 }
  default { $embeddingMode = "local"; $embedIdx = 0 }
}

$embedProvider = $EMBED_PROVIDERS[$embedIdx]
$displayModel = if ([string]::IsNullOrWhiteSpace($embedProvider.Model)) { $OLLAMA_LOCAL_MODEL } else { $embedProvider.Model }
Write-Host ("  -> Selected: {0} ({1})" -f $embedProvider.Name, $displayModel)
Write-Host ""

# Re-install detection
$reinstallConfirmed = $false
if ($embeddingMode -eq "local" -and (Test-LocalInstalled)) {
  if (Confirm-Reinstall "local (Ollama + $OLLAMA_LOCAL_MODEL)") {
    $reinstallConfirmed = $true
  } else {
    Write-Host "  -> Local re-install cancelled; keeping existing config. Continuing with the rest of the install..."
    $embeddingMode = "keep"
  }
} elseif ($embeddingMode -eq "api" -and (Test-ApiConfigured)) {
  if (Confirm-Reinstall "api ($($embedProvider.Name))") {
    $reinstallConfirmed = $true
  } else {
    Write-Host "  -> API re-configuration cancelled; keeping existing config. Continuing with the rest of the install..."
    $embeddingMode = "keep"
  }
}

# For api mode, collect and validate key up-front. Loops until valid.
$apiKey = ""
if ($embeddingMode -eq "api") {
  Write-Host ""
  Write-Host ("  You chose {0} with model {1}." -f $embedProvider.Name, $embedProvider.Model)
  Write-Host ("  Endpoint: {0}" -f $embedProvider.Url)
  Write-Host ""
  while ($true) {
    $secureKey = Read-Host "  Enter API key for $($embedProvider.Name) (input hidden)" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
    $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
      Write-Host "  x API key is required. Press Ctrl+C to abort." -ForegroundColor Red
      continue
    }
    Write-Host "  . Validating key by issuing a test embed request..."
    if (Test-EmbeddingApiKey -Url $embedProvider.Url -Model $embedProvider.Model -Key $apiKey) {
      Write-Host "  OK Key is valid (endpoint responded 200)" -ForegroundColor Green
      break
    } else {
      Write-Host "  x Validation failed. The endpoint did not return 200 (check key, model access, or network)." -ForegroundColor Red
      Write-Host "    Try again, or press Ctrl+C to abort."
    }
  }
}

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

# --- Inject Engram Embedding Layer ---
Write-Host ""
Write-Host "Injecting semantic search (embedding layer) into Engram..."

$engramSrc = Join-Path $env:USERPROFILE ".claude\plugins\marketplaces\engram"
$patchUrl = "$REPO_URL/patches/engram-embedding.patch"

if (-not (Test-Path $engramSrc)) {
  Write-Host "  ! Engram source not found at $engramSrc" -ForegroundColor Yellow
  Write-Host "  Semantic search will not be available until Engram is installed."
  $warnings += "Engram source not found — embedding layer skipped"
} else {
  $embeddingDir = Join-Path $engramSrc "internal\embedding"

  # Check if embedding layer is already applied (idempotent)
  if (Test-Path $embeddingDir) {
    Write-Host "  OK Embedding layer already applied — skipping patch" -ForegroundColor Green
  } else {
    # Download and apply patch
    $patchTmp = Join-Path $env:TEMP "engram-embedding.patch"
    try {
      Invoke-WebRequest -Uri $patchUrl -OutFile $patchTmp -UseBasicParsing

      Push-Location $engramSrc
      $checkResult = & git apply --check $patchTmp 2>&1
      if ($LASTEXITCODE -eq 0) {
        & git apply $patchTmp
        Write-Host "  OK Embedding patch applied" -ForegroundColor Green
      } else {
        Write-Host "  ! Patch does not apply cleanly — trying 3-way merge..." -ForegroundColor Yellow
        & git apply --3way $patchTmp 2>&1
        if ($LASTEXITCODE -eq 0) {
          Write-Host "  OK Embedding patch applied (3-way merge)" -ForegroundColor Green
        } else {
          Write-Host "  ! Embedding patch failed — semantic search not available" -ForegroundColor Red
          $warnings += "Embedding patch failed to apply"
        }
      }
      Pop-Location
      Remove-Item $patchTmp -Force -ErrorAction SilentlyContinue
    } catch {
      Write-Host "  ! Failed to download embedding patch" -ForegroundColor Red
      $warnings += "Failed to download embedding patch from $patchUrl"
    }
  }

  # Rebuild engram binary if embedding layer exists
  if (Test-Path $embeddingDir) {
    Write-Host "  . Rebuilding engram binary with embedding support..."

    # Find current engram binary location
    $engramBinCmd = Get-Command engram -ErrorAction SilentlyContinue
    if ($engramBinCmd) {
      $engramBin = $engramBinCmd.Source
    } else {
      $engramBin = Join-Path (& go env GOPATH 2>$null) "bin\engram.exe"
    }

    Push-Location $engramSrc
    & go build -o $engramBin ./cmd/engram/ 2>$null
    if ($LASTEXITCODE -eq 0) {
      Write-Host "  OK Engram rebuilt with semantic search support" -ForegroundColor Green
    } else {
      Write-Host "  ! Engram rebuild failed — check Go installation" -ForegroundColor Red
      $warnings += "Engram rebuild failed — embedding layer applied but binary not updated"
    }
    Pop-Location
  }
}

# --- Configure Embedding Backend (local Ollama or remote API) ---
# Dual-mode design: both configurations can coexist. A wrapper script reads
# %USERPROFILE%\.engram\mode at each MCP launch to select which backend is active.
Write-Host ""
Write-Host "Configuring embedding backend..."

New-Item -ItemType Directory -Path $ENGRAM_STATE_DIR -Force | Out-Null

# Install Ollama + pull bge-m3 for local mode
if ($embeddingMode -eq "local") {
  if ($reinstallConfirmed) {
    Write-Host "  . Wiping previous local setup (model only; Ollama binary is preserved)..."
    & ollama rm $OLLAMA_LOCAL_MODEL 2>$null | Out-Null
  }

  if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Host "  . Installing Ollama via scoop..."
    try {
      & scoop install ollama 2>$null
      if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) { throw "ollama still not in PATH" }
      Write-Host "  OK Ollama installed" -ForegroundColor Green
    } catch {
      Write-Host "  ! scoop install failed; downloading Ollama installer from ollama.com..." -ForegroundColor Yellow
      try {
        $ollamaInst = Join-Path $env:TEMP "OllamaSetup.exe"
        Invoke-WebRequest -Uri "https://ollama.com/download/OllamaSetup.exe" -OutFile $ollamaInst -UseBasicParsing
        Start-Process -FilePath $ollamaInst -ArgumentList "/SILENT" -Wait
        Remove-Item $ollamaInst -Force -ErrorAction SilentlyContinue
        # Refresh PATH from registry
        $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
        if (Get-Command ollama -ErrorAction SilentlyContinue) {
          Write-Host "  OK Ollama installed via direct download" -ForegroundColor Green
        } else {
          throw "Ollama still not in PATH after direct install"
        }
      } catch {
        Write-Host "  ! Ollama install failed — semantic search will fall back to TF-IDF" -ForegroundColor Red
        $warnings += "Ollama install failed — local embedding mode unavailable"
        $embeddingMode = "none"
      }
    }
  } else {
    Write-Host "  OK Ollama already present" -ForegroundColor Green
  }

  if ($embeddingMode -eq "local") {
    # Ensure Ollama daemon is running
    try {
      $null = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    } catch {
      Write-Host "  . Starting Ollama service in background..."
      Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden -PassThru | Out-Null
      for ($i = 0; $i -lt 10; $i++) {
        Start-Sleep -Seconds 1
        try {
          $null = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
          break
        } catch { }
      }
    }

    # Pull model (idempotent — skips if already present)
    $listOut = & ollama list 2>$null
    if ($listOut -match "^$OLLAMA_LOCAL_MODEL(\s|:)") {
      Write-Host "  OK Model $OLLAMA_LOCAL_MODEL already present" -ForegroundColor Green
    } else {
      Write-Host "  . Pulling $OLLAMA_LOCAL_MODEL (~2.3GB, this may take several minutes)..."
      & ollama pull $OLLAMA_LOCAL_MODEL
      if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK Model $OLLAMA_LOCAL_MODEL pulled" -ForegroundColor Green
      } else {
        Write-Host "  ! Model pull failed — semantic search will fall back to TF-IDF" -ForegroundColor Red
        $warnings += "Ollama pull $OLLAMA_LOCAL_MODEL failed"
        $embeddingMode = "none"
      }
    }
  }
}

# Store API credentials for api mode
if ($embeddingMode -eq "api") {
  Set-Content -Path (Join-Path $ENGRAM_STATE_DIR "api-url")      -Value $embedProvider.Url   -NoNewline
  Set-Content -Path (Join-Path $ENGRAM_STATE_DIR "api-model")    -Value $embedProvider.Model -NoNewline
  Set-Content -Path (Join-Path $ENGRAM_STATE_DIR "api-provider") -Value $embedProvider.Name  -NoNewline

  $storeMethod = Save-ApiKeySecure -Key $apiKey
  Write-Host "  OK API key stored in: $storeMethod" -ForegroundColor Green
  # Clear plaintext from memory
  $apiKey = $null
  Remove-Variable apiKey -ErrorAction SilentlyContinue
}

# Write the active mode marker AFTER successful configuration of the chosen mode.
if ($embeddingMode -ne "keep") {
  Set-Content -Path (Join-Path $ENGRAM_STATE_DIR "mode") -Value $embeddingMode -NoNewline
}

# Write the wrapper PowerShell script that selects the backend at each MCP launch.
$wrapperPath = Join-Path $ENGRAM_STATE_DIR "engram-wrapper.ps1"
$wrapperContent = @'
# Managed by autoSDD installer — do not edit directly.
# Selects the embedding backend based on %USERPROFILE%\.engram\mode, then launches engram mcp.

$ErrorActionPreference = "Stop"
$stateDir = Join-Path $env:USERPROFILE ".engram"
$modeFile = Join-Path $stateDir "mode"
$mode = if (Test-Path $modeFile) { (Get-Content $modeFile -Raw).Trim() } else { "local" }

switch ($mode) {
  "local" {
    $env:ENGRAM_EMBEDDING_PROVIDER  = "api"
    $env:ENGRAM_EMBEDDING_API_URL   = "__OLLAMA_URL__"
    $env:ENGRAM_EMBEDDING_API_MODEL = "__OLLAMA_MODEL__"
    $env:ENGRAM_EMBEDDING_API_KEY   = "ollama"
  }
  "api" {
    $env:ENGRAM_EMBEDDING_PROVIDER  = "api"
    $env:ENGRAM_EMBEDDING_API_URL   = (Get-Content (Join-Path $stateDir "api-url")   -Raw).Trim()
    $env:ENGRAM_EMBEDDING_API_MODEL = (Get-Content (Join-Path $stateDir "api-model") -Raw).Trim()
    $keyPath = Join-Path $stateDir "api-key.dpapi"
    $key = ""
    if (Test-Path $keyPath) {
      try {
        $encrypted = Get-Content $keyPath -Raw
        $secure = ConvertTo-SecureString -String $encrypted
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        $key = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
      } catch { }
    }
    $env:ENGRAM_EMBEDDING_API_KEY = $key
  }
  default {
    $env:ENGRAM_EMBEDDING_PROVIDER = "local"
  }
}

$engramCmd = Get-Command engram -ErrorAction SilentlyContinue
if (-not $engramCmd) {
  Write-Error "engram binary not found in PATH — cannot start MCP server"
  exit 1
}
& $engramCmd.Source mcp --tools=agent @args
exit $LASTEXITCODE
'@

$wrapperContent = $wrapperContent.Replace("__OLLAMA_URL__",   $OLLAMA_LOCAL_URL)
$wrapperContent = $wrapperContent.Replace("__OLLAMA_MODEL__", $OLLAMA_LOCAL_MODEL)
Set-Content -Path $wrapperPath -Value $wrapperContent -NoNewline
Write-Host "  OK Wrapper installed at $wrapperPath" -ForegroundColor Green

# Point Claude Code's MCP config at the wrapper
$claudeMcpDir = Join-Path $env:USERPROFILE ".claude\mcp"
if (Test-Path $claudeMcpDir) {
  $claudeMcp = Join-Path $claudeMcpDir "engram.json"
  $mcpConfig = @{
    command = "powershell.exe"
    args    = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $wrapperPath)
  } | ConvertTo-Json -Compress
  Set-Content -Path $claudeMcp -Value $mcpConfig -NoNewline
  Write-Host "  OK Claude Code MCP config rewired to wrapper" -ForegroundColor Green
} else {
  Write-Host "  ! $claudeMcpDir not found - skipped MCP rewire" -ForegroundColor Yellow
}

$activeMode = if (Test-Path (Join-Path $ENGRAM_STATE_DIR "mode")) { (Get-Content (Join-Path $ENGRAM_STATE_DIR "mode") -Raw).Trim() } else { "local" }
Write-Host "  -> Active embedding mode: $activeMode"

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

# 3. Install bundled skills (from autoSDD repo itself)
$BUNDLED_SKILLS = @("feedback-report", "knowledge-graph")
foreach ($skill in $BUNDLED_SKILLS) {
  for ($i = 0; $i -lt $AGENTS.Count; $i++) {
    $agent = $AGENTS[$i]
    if ($selectedAgents -contains $agent) {
      $skillDir = Join-Path $AGENT_DIRS[$i] "skills/$skill"
      New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
      try {
        Invoke-WebRequest -Uri "$REPO_URL/skills/$skill/SKILL.md" -OutFile (Join-Path $skillDir "SKILL.md") -UseBasicParsing
        Write-Host "  OK $skill ($agent)"
      } catch {
        $msg = "Failed to install $skill for $agent"
        Write-Host "  ! $msg" -ForegroundColor Yellow
        $warnings += $msg
      }
    }
  }
}

# 4. Install shared protocols (extracted from CLAUDE.md for slim index)
$SHARED_FILES = @("persona.md", "rtk.md", "sdd-orchestrator.md", "engram-protocol.md", "model-assignments.md")
Write-Host ""
Write-Host "Installing shared protocols..."
for ($i = 0; $i -lt $AGENTS.Count; $i++) {
  $agent = $AGENTS[$i]
  if ($selectedAgents -contains $agent) {
    $sharedDir = Join-Path $AGENT_DIRS[$i] "skills/_shared"
    New-Item -ItemType Directory -Path $sharedDir -Force | Out-Null
    foreach ($sf in $SHARED_FILES) {
      try {
        Invoke-WebRequest -Uri "$REPO_URL/shared/$sf" -OutFile (Join-Path $sharedDir $sf) -UseBasicParsing
      } catch {
        $msg = "Failed to install shared/$sf for $agent"
        $warnings += $msg
      }
    }
    Write-Host "  OK shared protocols ($agent)"
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
    $coreSkillNames = @("autosdd") + ($SKILLS_SH | ForEach-Object { $_.skill }) + $BUNDLED_SKILLS
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

# Check embedding layer (Go patch applied + binary rebuilt)
$embeddingCheck = Join-Path $env:USERPROFILE ".claude\plugins\marketplaces\engram\internal\embedding"
if (Test-Path $embeddingCheck) {
  Write-Host "  [OK] Engram embedding layer" -ForegroundColor Green
} else {
  Write-Host "  [..] Engram embedding layer not applied" -ForegroundColor Yellow
}

# Check embedding backend configuration
$modeFile    = Join-Path $ENGRAM_STATE_DIR "mode"
$wrapperFile = Join-Path $ENGRAM_STATE_DIR "engram-wrapper.ps1"
if ((Test-Path $modeFile) -and (Test-Path $wrapperFile)) {
  $active = (Get-Content $modeFile -Raw).Trim()
  switch ($active) {
    "local" {
      $listOut = & ollama list 2>$null
      if ($listOut -match "^$OLLAMA_LOCAL_MODEL(\s|:)") {
        Write-Host "  [OK] Embedding backend: local ($OLLAMA_LOCAL_MODEL via Ollama)" -ForegroundColor Green
      } else {
        Write-Host "  [!!] Embedding backend: local but Ollama/bge-m3 missing" -ForegroundColor Red
        $allGood = $false
      }
    }
    "api" {
      $providerName  = (Get-Content (Join-Path $ENGRAM_STATE_DIR "api-provider") -Raw).Trim()
      $modelName     = (Get-Content (Join-Path $ENGRAM_STATE_DIR "api-model")    -Raw).Trim()
      Write-Host "  [OK] Embedding backend: api ($providerName, $modelName)" -ForegroundColor Green
    }
    default {
      Write-Host "  [..] Embedding backend: $active (no semantic search, TF-IDF fallback)" -ForegroundColor Yellow
    }
  }
} else {
  Write-Host "  [..] Embedding backend not configured" -ForegroundColor Yellow
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
