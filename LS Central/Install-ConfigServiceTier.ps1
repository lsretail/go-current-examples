Import-Module GoCurrent
<#
    .SYNOPSIS
        Install LS Central and change various service tier configs.
#>

# The bc-server has many parameters that configure the servier (update
# CustomSettings.config), their name should match the settings key.
# If a parameter does not exists for a setting, you can create a JSON
# string with the settings you want to update and pass that to
# the SettingsJson parameter.
$ServerSettings = @{
    SqlCommandTimeout = '01:30:00'
}

$Arguments = @{
    'bc-server' = @{
        DeveloperServicesEnabled = 'true'
        # Here we convert the hashtable to a json string and pass that as an argument:
        SettingsJson = (ConvertTo-Json $ServerSettings -Compress).ToString()
    }
}

$Packages = @(
    # Uncomment to install SQL Express:
    #@{ Id = 'sql-server-express'; VersionQuery = '^-'}
    @{ Id = 'ls-central-demo-database'; VersionQuery = '^'}
    @{ Id = 'ls-central-app'; VersionQuery = '^'}
    @{ Id = 'ls-central-toolbox-server'; VersionQuery = '^'}
    @{ Id = 'ls-dd-server-addin'; VersionQuery = '^'}
    @{ Id = 'bc-system-symbols'; VersionQuery = '^'}
    @{ Id = 'bc-base-application'; VersionQuery = '^'}
    @{ Id = 'bc-web-client'; VersionQuery = ''}
)

$Packages | Install-GocPackage -Arguments $Arguments -InstanceName 'LSCentral'
