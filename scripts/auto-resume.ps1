#Requires -Version 5.1

<#
.SYNOPSIS
    Claude CLI wrapper with automatic rate-limit recovery.
.DESCRIPTION
    Part of autoSDD. Enabled by default.
    Detects rate limits, waits for reset, resumes conversation automatically.
.PARAMETER NoResume
    Disable auto-resume (passthrough to claude).
.PARAMETER ArVersion
    Show version and exit.
.PARAMETER ClaudeArgs
    Arguments passed through to claude CLI.
.NOTES
    Environment variables:
      AUTOSDD_AUTO_RESUME=false   Disable auto-resume
      AUTOSDD_MAX_RETRIES=10      Max retry attempts
      AUTOSDD_BUFFER_SECS=30      Extra wait after reset time
      AUTOSDD_DEFAULT_WAIT=120    Default wait when time can't be parsed
#>
[CmdletBinding()]
param(
    [switch]$NoResume,
    [switch]$ArVersion,
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$ClaudeArgs = @()
)

$ErrorActionPreference = "Stop"
$script:Version = "1.0.0"
$MaxRetries   = if ($env:AUTOSDD_MAX_RETRIES)  { [int]$env:AUTOSDD_MAX_RETRIES }  else { 10 }
$BufferSecs   = if ($env:AUTOSDD_BUFFER_SECS)  { [int]$env:AUTOSDD_BUFFER_SECS }  else { 30 }
$DefaultWait  = if ($env:AUTOSDD_DEFAULT_WAIT)  { [int]$env:AUTOSDD_DEFAULT_WAIT } else { 120 }

if ($ArVersion) {
    Write-Host "autosdd-resume v$($script:Version)"
    exit 0
}

if ($env:AUTOSDD_AUTO_RESUME -eq "false" -or $NoResume) {
    & claude @ClaudeArgs
    exit $LASTEXITCODE
}

if ($ClaudeArgs -notcontains "--dangerously-skip-permissions") {
    $ClaudeArgs = @("--dangerously-skip-permissions") + $ClaudeArgs
}

# ── Utilities ─────────────────────────────────────────────────────────────────

function Test-RateLimited {
    param([string]$Text)
    $clean = $Text -replace '\x1b\[[0-9;]*[a-zA-Z]', '' -replace '\r', ''
    return ($clean -match 'rate.?limit|hit.?(your|the).?limit|resets?\s+[0-9]')
}

function Get-WaitSeconds {
    param([string]$Text)
    $clean = $Text -replace '\x1b\[[0-9;]*[a-zA-Z]', '' -replace '\r', ''

    if ($clean -match '(\d{1,2}:\d{2}\s*(am|pm)?)') {
        $timeStr = $Matches[1]
        try {
            $resetTime = [DateTime]::Parse($timeStr)
            if ($resetTime -lt [DateTime]::Now) {
                $resetTime = $resetTime.AddDays(1)
            }
            $wait = [int]($resetTime - [DateTime]::Now).TotalSeconds + $BufferSecs
            if ($wait -lt 30)   { return $DefaultWait }
            if ($wait -gt 3600) { return 3600 }
            return $wait
        } catch {
            return $DefaultWait
        }
    }
    return $DefaultWait
}

function Show-Countdown {
    param([int]$Seconds)
    for ($s = $Seconds; $s -gt 0; $s--) {
        $min = [math]::Floor($s / 60)
        $sec = $s % 60
        Write-Host -NoNewline ("`r  Resuming in {0:D2}:{1:D2} " -f $min, $sec)
        Start-Sleep -Seconds 1
    }
    Write-Host "`r  Resuming now...                   "
}

# ── Main loop ─────────────────────────────────────────────────────────────────

$attempt = 0
$isResume = $false

while ($attempt -lt $MaxRetries) {
    $outputLines = @()
    $rc = 0

    try {
        if ($isResume) {
            & claude --dangerously-skip-permissions -c 2>&1 | ForEach-Object {
                Write-Host $_
                $outputLines += $_
            }
        } else {
            & claude @ClaudeArgs 2>&1 | ForEach-Object {
                Write-Host $_
                $outputLines += $_
            }
        }
        $rc = if ($null -ne $LASTEXITCODE) { $LASTEXITCODE } else { 0 }
    } catch {
        $rc = 1
    }

    $output = $outputLines -join "`n"

    if (Test-RateLimited $output) {
        $attempt++
        Write-Host ""
        Write-Host "  [autosdd-resume] Rate limit hit (attempt $attempt/$MaxRetries)"
        $wait = Get-WaitSeconds $output
        Write-Host "  [autosdd-resume] Waiting ${wait}s for reset..."
        Show-Countdown $wait
        $isResume = $true
    } else {
        exit $rc
    }
}

Write-Host "  [autosdd-resume] Max retries ($MaxRetries) reached."
exit 1
