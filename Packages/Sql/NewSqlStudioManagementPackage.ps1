param(
    [Parameter(Mandatory)]
    $SetupPath,
    [Parameter(Mandatory)]
    $OutputDir,
    $Server,
    $Port,
    [Switch] $Force,
    [Switch] $Import
)

$ErrorActionPreference = 'stop'

$FileName = Split-Path $SetupPath -Leaf

if ($FileName -ine 'SSMS-Setup-ENU.exe')
{
    throw "Setup file name must be SSMS-Setup-ENU.exe."
}

$Management = @{
    Id = 'sql-management-studio'
    Name = 'SQL Management Studio'
    Version = $SetupPath
    InputPath = @(
        $SetupPath,
        (Join-Path (Join-Path $PSScriptRoot 'sql-management-studio') '*')
    )
    OutputDir = $OutputDir
    Commands = @{
        Install = 'Package.psm1:Install-Package'
    }
    Instance = $false
}

$Package = New-GocsPackage @Management -Force:$Force 
if ($Import)
{
    $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
}
$Package
