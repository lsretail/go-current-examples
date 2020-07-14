$ErrorActionPreference = 'stop'

Import-Module GoCurrentServer
Import-Module LsSetupHelper\Release\Version

function New-ChromePackageFromWeb
{
    param(
        $Server,
        $Port,
        $OutputDir,
        [Switch] $Import,
        [switch] $Force
    )

    $Uri = 'http://dl.google.com/chrome/install/375.126/chrome_installer.exe'
    $Path = Join-Path $OutputDir 'Chrome.exe'

    if (!$Force -and (Test-Path $Path))
    {
        throw "File already exists $Path"
    }

    Invoke-WebRequest -UseBasicParsing -OutFile $Path -Uri $Uri

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).ProductVersion.Trim()
    $Version = Format-Version -Version $Version -Places 3
    
    if ($Force -or !(Test-GocsPackage -id 'chrome' -Version $Version -Server $Server -Port $Port))
    {
        $Package = New-ChromePackage -Path $Path -OutputDir $OutputDir -Force:$Force
        if ($Import)
        {
            $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
        }
        $Package
    }
}

function New-ChromePackage
{
    param(
        [Parameter(Mandatory = $true)]
        $Path,
        [Parameter(Mandatory = $true)]
        $OutputDir,
        [switch]$Force
    )

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).ProductVersion.Trim()
    $Version = Format-Version -Version $Version -Places 3

    $Package = @{
        Id = 'chrome'
        Name = 'Chrome'
        Description = 'Get more done with the new Chrome'
        Version = $Version
        Commands = @{
            Install = 'Package.psm1:Install-Package'
            Remove = 'Package.psm1:Remove-Package'
        }
        InputPath = @(
            Join-Path $PSScriptRoot 'package\*'
            $Path
        )
        OutputDir = $OutputDir
    }
    
    New-GocsPackage @Package -Force:$Force
}