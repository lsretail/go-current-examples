#requires -RunAsAdministrator
<#
    .SYNOPSIS
        Install the latest LS Central version.
#>
$ErrorActionPreference = 'stop'
Import-Module GoCurrent

$Arguments = @{
    'bc-server' = @{
        AllowSessionCallSuspendWhenWriteTransactionStarted = 'true'
    }
}

$Packages = @(
    # Optional, uncomment to include:
    #@{ Id = 'sql-server-express'; VersionQuery = '^-'}
    @{ Id = 'ls-central-demo-database'; Version = '' }
    @{ Id = 'bc-server'; Version = '' }
    @{ Id = 'bc-web-client'; Version = '' }
    @{ Id = 'bc-system-symbols'; Version = '' }
    @{ Id = 'bc-system-application-runtime'; Version = '' }
    @{ Id = 'bc-base-application-runtime'; Version = '' }
    @{ Id = 'ls-central-app-runtime'; Version = '' }
)
 
$Packages | Install-GocPackage -InstanceName 'LSCentral' -Arguments $Arguments