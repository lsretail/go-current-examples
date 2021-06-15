param(
    $Target = 'Dev',
    $Server,
    $Port,
    [switch] $Force
)
$ErrorActionPreference = 'stop'
Import-Module GoCurrentServer

$PackagesDir = Join-Path $PSScriptRoot "..\Packages\$Target"

if (!(Test-Path $PackagesDir))
{
    throw "No packages do deploy."
}

Import-GocsPackage -Path (Join-Path $PackagesDir '*') -Server $Server -Port $Port -Force:$Force