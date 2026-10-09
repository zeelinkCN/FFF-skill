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
    [ValidateSet('dsh', 'claude', 'codex')]
    [string[]]$Only
)

$ErrorActionPreference = 'Stop'

$source = Join-Path $PSScriptRoot 'SKILL.md'
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "SKILL.md not found next to this script: $source"
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
