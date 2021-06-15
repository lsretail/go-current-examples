<#
    .SYNOPSIS
        Install latest Cronus release.

    .DESCRIPTION
        This script will install the latest release of the Cronus apps on top
        of LS Central.
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
    @{ Id = 'cronus-base-app'; VersionQuery = ''}
    @{ Id = 'cronus-api-app'; VersionQuery = ''}

    @{ Id = 'bc-cronus-license'; VersionQuery = ''}
)

$Packages | Get-GocUpdates -InstanceName 'Cronus'
$Packages | Install-GocPackage -InstanceName 'Cronus' -UpdateStrategy 'Manual' -Arguments $Arguments