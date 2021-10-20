$ErrorActionPreference = 'stop'

Import-Module GoCurrentServer

function New-SqlStudioPackageFromWeb
{
    param(
        [Parameter(Mandatory = $true)]
        $OutputDir,
        $Server,
        $Port,
        [switch] $Force,
        [switch] $Import
    )

    $Path = Join-Path $OutputDir 'SSMS-Setup-ENU.exe'

    if (!$Force -and (Test-Path $Path))
    {
        throw "File $Path already exists."
    }
    Invoke-WebRequest -UseBasicParsing -Uri 'https://aka.ms/ssmsfullsetup' -OutFile $Path

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).ProductVersion.Trim()
   
    if ($Force -or !(Test-GocsPackage -Id 'sql-management-studio' -Version $Version -Server $Server -Port $Port))
    {
        $Script = (Join-Path $PSScriptRoot '..\..\Sql\NewSqlStudioManagementPackage.ps1')
        & $Script -SetupPath $Path -OutputDir $OutputDir -Force:$Force -Import:$Import -Server $Server -Port $Port
    }
}