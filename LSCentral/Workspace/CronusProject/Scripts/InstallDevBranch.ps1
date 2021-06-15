param(
    $BranchName = 'my-branch'
)

<#
    .SYNOPSIS
        Install branch snapshot.

    .DESCRIPTION
        This script will install the selected branch, $BranchName. If it does 
        not exists, it will fallback to the master branch.
#>

$ErrorActionPreference = 'stop'

Import-Module GoCurrent

Import-Module LsPackageTools\Workspace

$VersionQueryBranchFilter = ConvertTo-BranchPriorityPreReleaseFilter -BranchName @($BranchName, 'master')

Write-Host $VersionQueryBranchFilter

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
    @{ Id = 'cronus-base-app'; VersionQuery = "^ $VersionQueryBranchFilter"}
    @{ Id = 'cronus-api-app'; VersionQuery = "^ $VersionQueryBranchFilter"}

    @{ Id = 'bc-cronus-license'; VersionQuery = ''}
)

$Packages | Get-GocUpdates -InstanceName 'CronusDev'
$Packages | Install-GocPackage -InstanceName 'CronusDev' -UpdateStrategy 'Manual' -Arguments $Arguments