$ErrorActionPreference = 'stop'

Import-Module GoCurrentServer
Import-Module LsSetupHelper\Release\Version

function New-ServiceTierAdministratorPackageFromWeb
{
    param(
        $Server,
        $Port,
        $OutputDir,
        [Switch] $Import,
        [switch] $Force
    )

    $ZipPath = Join-Path $OutputDir 'ServiceTierAdministrator.zip'
    $Dir = Join-Path $OutputDir 'ServiceTierAdministrator'

    if (!$Force -and (Test-Path $ZipPath))
    {
        throw "File already exists $ZipPath"
    }

    if (!$Force -and (Test-Path $Dir))
    {
        throw "Dir already exists: $Dir"
    }

    Remove-Item -Path $Dir -Recurse -ErrorAction SilentlyContinue

    Invoke-WebRequest -UseBasicParsing -OutFile $ZipPath -Uri 'https://mibuso.com/?ACT=112&key=eC9IOHJVNGgwY1RnWDF1RnlNaDZCL0xRUTVockFXVVBLQi8rYzFnZlZDSlBKWGJUN2dUbGVsYU9HM0JCcU1jbHVVVDg0S0dmRC9mME9ZV1hIcnpQdjYvUlNHNW5MVnJuWmlJS3Boc29LOGpEQmMrL1M3M1JJbHEyRWRpQkRqKzg='

    Expand-Archive -Path $ZipPath -DestinationPath $Dir

    $Path = Join-Path $Dir '*.exe' -Resolve

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).ProductVersion.Trim()

    if ($Force -or !(Test-GocsPackage -id 'service-tier-administration' -Version $Version -Server $Server -Port $Port))
    {
        $Package = New-ServiceTierAdministratorPackage -Path $Path -OutputDir $OutputDir -Force:$Force
        if ($Import)
        {
            $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
        }
        $Package
    }
}

function New-ServiceTierAdministratorPackage
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
        Id = 'service-tier-administration'
        Name = 'Service Tier Administration Tool'
        Description = 'A free Service Tier Administration Tool. All functionalities are working on LOCAL and REMOTE machines when you have the administration rights to that machine. Installing, Uninstalling, Start, Stop, Restart and dynamic change of settings like Portsharing, Account, start mode and settings in the CustomSettings.config of the Service Tier.'
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