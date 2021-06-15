#requires -RunAsAdministrator
<#
    .SYNOPSIS
        Install LS Central and create an empty database with a new company in the process.
    
    .DESCRIPTION
        This script will install LS Central and create a new empty database in the prcess.
        After the installation it will load the Business Central management module and 
        create a new company in you new database.
#>
$ErrorActionPreference = 'stop'
Import-Module GoCurrent

$Arguments = @{
    'bc-server' = @{
        NewDatabase = 'true'
        AllowSessionCallSuspendWhenWriteTransactionStarted = 'true'
    }
}

$Packages = @(
    # Optional, uncomment to include:
    #@{ Id = 'sql-server-express'; VersionQuery = '^-'}
    @{ Id = 'bc-server'; Version = '' }
    @{ Id = 'bc-web-client'; Version = '' }
    @{ Id = 'bc-system-symbols'; Version = '' }
    @{ Id = 'bc-system-application-runtime'; Version = '' }
    @{ Id = 'bc-base-application-runtime'; Version = '' }
    @{ Id = 'ls-central-app-runtime'; Version = '' }
    @{ Id = 'map/ls-central-to-bc'; Version = '' }
)

$InstanceName = 'LSCentral'

$Packages | Install-GocPackage -InstanceName $InstanceName -Arguments $Arguments

# Get information about our newly installed instance:
$BcServer = Get-GocInstalledPackage -Id 'bc-server' -InstanceName $InstanceName

# Import the Business Central management cmdlets:
Import-Module (Join-Path $BcServer.Info.ServerDir 'Microsoft.Dynamics.Nav.Management.dll')

# Create a new company:
New-NAVCompany -CompanyName 'GoCurrent' -ServerInstance $BcServer.Info.ServerInstance