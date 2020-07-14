$ErrorActionPreference = 'stop'

Import-Module GoCurrentServer

function New-EpsonOposAdkPackage
{
    <#
        .SYNOPSIS
            Create a new GoC package for Epson OPOS ADK.

        .PARAMETER SetupDir
            Setup directory containing Epson OPOS ADK setup file, including setup.iss and OposData.reg files.

        .PARAMETER OutputDir
            Output directory where package is created.
    #>
    param(
        [Parameter(Mandatory = $true)]
        $SetupDir,
        [Parameter(Mandatory = $true)]
        $OutputDir
    )

    $SetupDir = (Resolve-Path $SetupDir).ProviderPath

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo((Join-Path $SetupDir 'setup.exe')).FileVersion

    $Package = @{
        'Id' = "epson-opos-adk"
        'Name' = 'Epson OPOS ADK'
        'Version' = $Version
        'Include' = @(
            (Join-Path $PSScriptRoot 'epson-opos-adk\*')
            (Join-Path $SetupDir '*')
        )
        'OutputDir' = $OutputDir
        'Commands' = @{
            'Install' = 'Package.psm1:Install-Package'
            'Update' = 'Package.psm1:Update-Package'
        }
    }

    New-GocsPackage @Package -Force
}