#requires -RunAsAdministrator
<#
    .SYNOPSIS
        Install LS Central and change various service tier configs.
#>
$ErrorActionPreference = 'stop'
Import-Module GoCurrent

# The bc-server has many parameters that configure the servier (update
# CustomSettings.config), their name should match the settings key.
# If a parameter does not exists for a setting, you can create a JSON
# string with the settings you want to update and pass it to
# the SettingsJson parameter.
$ServerSettings = @{
    SqlCommandTimeout = '01:30:00'
}

$Arguments = @{
    'bc-server' = @{
        DeveloperServicesEnabled = 'true'
        AllowSessionCallSuspendWhenWriteTransactionStarted = 'true'
        # Here we convert the hashtable to a json string and pass that as an argument:
        SettingsJson = (ConvertTo-Json $ServerSettings -Compress).ToString()
    }
}

$Packages = @(
    # Uncomment to install SQL Express:
    #@{ Id = 'sql-server-express'; VersionQuery = '^-'}
    @{ Id = 'ls-central-demo-database'; Version = '' }
    @{ Id = 'bc-server'; Version = '' }
    @{ Id = 'bc-web-client'; Version = '' }
    @{ Id = 'bc-system-symbols'; Version = '' }
    @{ Id = 'bc-system-application-runtime'; Version = '' }
    @{ Id = 'bc-base-application-runtime'; Version = '' }
    @{ Id = 'ls-central-app-runtime'; Version = '' }
    @{ Id = 'map/ls-central-to-bc'; Version = '' }
)

$Packages | Install-GocPackage -Arguments $Arguments -InstanceName 'LSCentral'
