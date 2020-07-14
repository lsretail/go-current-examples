$ErrorActionPreference = 'stop'

Import-Module GoCurrentServer

function New-ToshibaUposPackage
{
    <#
        .SYNOPSIS
            Creates a new GoC package for Toshiba Upos.

        .PARAMETER SetupDir
            Setup directory containing Toshiba Upos setup file, including ISS file.

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

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo((Join-Path $SetupDir 'setup.exe')).ProductVersion

    $Package = @{
        'Id' = "toshiba-upos"
        'Name' = 'Toshiba UnifiedPOS'
        'Version' = $Version
        'Include' = @(
            (Join-Path $PSScriptRoot 'toshiba-upos\*')
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