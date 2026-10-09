#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Install the FFF skill into every agent home present on this machine.

.DESCRIPTION
    Copies SKILL.md (next to this script) to <home>/skills/fff/SKILL.md for:
      dsh     $DSH_HOME    or ~/.dsh      (DeepSeek Harness)
      claude  $CLAUDE_CONFIG_DIR or ~/.claude (Claude Code)
      codex   $CODEX_HOME  or ~/.codex    (Codex)
    A home that does not exist is skipped, so nothing is created for a tool
    you do not use. Existing copies are replaced when their content differs.

.PARAMETER Only
    Install into only these targets.

.EXAMPLE
    ./install.ps1
    ./install.ps1 -Only claude,codex
#>
[CmdletBinding()]
param(
    [string[]]$Only
)

$ErrorActionPreference = 'Stop'

# Validated by hand, not with [ValidateSet]: that attribute breaks `irm <url> | iex`,
# which is the one-liner install documented in the README.
$validTargets = 'dsh', 'claude', 'codex'
if ($Only) {
    $unknown = @($Only | Where-Object { $validTargets -notcontains $_ })
    if ($unknown.Count -gt 0) {
        throw "unknown target: $($unknown -join ', ') (use one of: $($validTargets -join ' '))"
    }
}

# Where to fetch SKILL.md from when this script runs without the repo next to it,
# for example:  irm https://cdn.jsdelivr.net/gh/zeelinkCN/FFF-skill@v1.0.3/install.ps1 | iex
# GitHub API first: raw.githubusercontent.com is blocked on many CN networks, and jsDelivr
# merely 301s *.md back to raw. The API endpoint answers wherever github.com is reachable.
$SourceUrls = if ($env:FFF_SKILL_URL) { @($env:FFF_SKILL_URL) } else { @(
        'https://api.github.com/repos/zeelinkCN/FFF-skill/contents/SKILL.md',
        'https://raw.githubusercontent.com/zeelinkCN/FFF-skill/main/SKILL.md'
    ) }
$SourceAccept = 'application/vnd.github.raw'

$source = if ($PSScriptRoot) { Join-Path $PSScriptRoot 'SKILL.md' } else { 'SKILL.md' }
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    $target = Join-Path ([System.IO.Path]::GetTempPath()) 'fff-skill.SKILL.md'
    $downloaded = $false
    $hasCurl = [bool](Get-Command curl.exe -ErrorAction SilentlyContinue)
    foreach ($url in $SourceUrls) {
        Write-Host "SKILL.md not found locally - downloading $url" -ForegroundColor DarkGray
        if ($hasCurl) {
            # curl.exe rather than Invoke-WebRequest: .NET's HttpClient is the part that stalls here.
            & curl.exe -fsSL -H "Accept: $SourceAccept" --connect-timeout 8 --max-time 45 -o $target $url
            if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $target -PathType Leaf)) { $downloaded = $true; break }
        }
        else {
            try {
                Invoke-WebRequest -Uri $url -Headers @{ Accept = $SourceAccept } -OutFile $target -TimeoutSec 30
                $downloaded = $true
                break
            }
            catch { Write-Host "  failed: $($_.Exception.Message)" -ForegroundColor Yellow }
        }
    }
    if (-not $downloaded) { throw "could not download SKILL.md from any of: $($SourceUrls -join ', ')" }
    $source = $target
}

$homes = [ordered]@{
    dsh    = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $HOME '.dsh' }
    claude = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
    codex  = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
}

$installed = 0
$sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash

foreach ($key in $homes.Keys) {
    if ($Only -and $Only -notcontains $key) { continue }

    $agentHome = $homes[$key]
    if (-not (Test-Path -LiteralPath $agentHome -PathType Container)) {
        Write-Host ("skip  {0,-6} ({1} not found)" -f $key, $agentHome) -ForegroundColor DarkGray
        continue
    }

    $destDir = Join-Path $agentHome 'skills/fff'
    $dest = Join-Path $destDir 'SKILL.md'
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null

    if ((Test-Path -LiteralPath $dest -PathType Leaf) -and
        (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash -eq $sourceHash) {
        Write-Host ("ok    {0,-6} {1} (already current)" -f $key, $dest) -ForegroundColor Green
    }
    else {
        Copy-Item -LiteralPath $source -Destination $dest -Force
        Write-Host ("done  {0,-6} {1}" -f $key, $dest) -ForegroundColor Cyan
    }
    $installed++
}

if ($installed -eq 0) {
    Write-Warning 'No agent home was found. Pass -Only <target> to create one anyway.'
}
