param(
    $Target,
    $BranchName,
    $Commit,
    $BuildNumber,
    [switch] $CleanOutput,
    [switch] $Force
)
$ErrorActionPreference = 'stop'

Import-Module LsPackageTools\Workspace

$ProjectDirs = @(
    (Join-Path $PSScriptRoot '..\Cronus.Base')
    (Join-Path $PSScriptRoot '..\Cronus.Api')
)

$Variables = @{
    BuildNumber = $BuildNumber
    Commit = $Commit
}

$OutputDir = (Join-Path $PSScriptRoot "..\Packages\$Target")

if ($CleanOutput -and (Test-Path $OutputDir))
{
    Remove-Item $OutputDir -Recurse -Force
}

Invoke-AlProjectBuild -ProjectDir $ProjectDirs -Target $Target -OutputDir $OutputDir -Variables $Variables -BranchName $BranchName -Force:$Force -Verbose