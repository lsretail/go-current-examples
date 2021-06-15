<#
    .SYNOPSIS
        Install latest Cronus release candidate.

    .DESCRIPTION
        This script will install the latest release candidate of the Cronus
        apps on top of LS Central.
#>
$ErrorActionPreference = 'stop'
Import-Module GoCurrent
$Arguments = @{
    'bc-server' = @{
        AllowForceSync = 'true'
    }
}

$LsCentralVersion = '18.0'

$Packages = @(
    # Optional, uncomment to include:
    #@{ Id = 'sql-server-express'; VersionQuery = '^-'}

    @{ Id = 'ls-central-demo-database'; VersionQuery = $LsCentralVersion}

    @{ Id = 'bc-web-client'; VersionQuery = ''}
    @{ Id = 'ls-central-app'; VersionQuery = $LsCentralVersion }
    @{ Id = 'map/ls-central-to-bc'; VersionQuery = $LsCentralVersion }
    @{ Id = 'cronus-base-app'; VersionQuery = '^ *-rc'}
    @{ Id = 'cronus-api-app'; VersionQuery = '^ *-rc'}

    @{ Id = 'bc-cronus-license'; VersionQuery = ''}
)

$Packages | Get-GocUpdates -InstanceName 'CronusRC'
$Packages | Install-GocPackage -InstanceName 'CronusRC' -UpdateStrategy 'Manual' -Arguments $Arguments