#requires -RunAsAdministrator
<#
    .SYNOPSIS
        Install LS Central and connect to existing Database.
    
    .PARAMETER SqlInstance
        SQL instance, servers host including instance name: HOSTNAME[\INSTANCENAME]

    .PARAMETER DatabaseName
        SQL database name.

    .PARAMETER BcVersion
        Business Central platform version, must match the database version.

    .PARAMETER InstanceName
        Go Current instance name to create.
    
    .NOTES
        Can be used with Business Central and NAV.
#>
param(
    $SqlInstance = 'localhost\SQLEXPRESS',
    $DatabaseName = 'DatabaseName',
    $BcVersion = '16.0.11233.12061',
    $InstanceName = 'BcInstance'
)

$ErrorActionPreference = 'stop'

Import-Module GoCurrent

$Arguments = @{
    'bc-server' = @{
        ConnectionString = "Data Source=$SqlInstance;Initial Catalog=$DatabaseName;Integrated Security=True"
        # This ensure Go Current will not update the database in any way, such as,
        # importing objects, apps or run database upgrade.
        # You can use this if you have another service tier that will handle the database upgrades, such as import new licenses and apps.
        NoDatabaseUpgrades = 'true'
    }
}

$Packages = @(  
    @{ Id = 'ls-central-toolbox-server'; VersionQuery = '' }
    @{ Id = 'ls-dd-server-addin'; VersionQuery = '' }
    @{ Id = 'bc-web-client'; VersionQuery = $BcVersion }
    @{ Id = 'bc-server'; VersionQuery = $BcVersion }
)
 
$Packages | Install-GocPackage -InstanceName $InstanceName -Arguments $Arguments