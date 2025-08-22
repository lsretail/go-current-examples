#requires -RunAsAdministrator
<#
    .SYNOPSIS
        Upgrade existing database with new versions of Business Central and LS Central.

    .DESCRIPTION
        This is an example of how you can use Update Service to upgrade your
        existing database, with a new Business Central platform, apps and
        LS Central. You can extend this with your own apps as well.

        You must have a database is place on a SQL server, then use this
        script to install a new service tier / NST, with the target
        BC platform version and with selected apps.

        Requirements for the existing databases:
        * Is running LS Central/Business Central 15.0 or above.
        * Database's platform version is the same or earlier version than the script will install.
        * All apps in the existing database are of the same version or earlier than listed in this script.

        Steps:

        1. Either:
            * Restore a database backup on your SQL server.
            * Backup existing database before running the upgrade, Update Service will not create a backup.
        2. Adjust the parameters:
            * ConnectionString: Connection string for your database.
            * BcPlatformVersion: The BC platform version of the database, before the upgrade.
            * LsCentralVersion: Your target LS Central version.
            * BcAppVersion: Your target Business Central (app) version.
                * If not specified then default LSC version is used.
            * InstanceName: Name for your Update Service instance and service tier created.
            * LicensePath: Optional, path to a new license file (.flf/.bclinese).
            (See note below)
        3. Run script.
#>
param(
    $ConnectionString = 'Data Source=${System.SqlServerInstance};Initial Catalog=${Package.InstanceName};Integrated Security=True',
    $BcPlatformVersion = '22.0',
    $TargetLsCentralVersion = '25.1',
    $InstanceName = 'Upgrade',
    $LicensePath
)
$ErrorActionPreference = 'stop'

$Arguments = @{
    'bc-server' = @{
        ConnectionString = $ConnectionString
        AllowSessionCallSuspendWhenWriteTransactionStarted = 'true'
        LicenseUri = $LicensePath
    }
}

# Install a service tier maching the database version.
$Packages = @(
    @{ Id = 'bc-server'; Version = $BcPlatformVersion }
)

$Packages | Install-UscPackage -InstanceName $InstanceName -Arguments $Arguments

# Upgrade to the specified LS Central version:
$Packages = @(
    @{ Id = 'bc-application'; Version = '' }
    @{ Id = 'map/ls-central-to-bc'; Version = $TargetLsCentralVersion }
    @{ Id = 'ls-central-app-runtime'; Version = $TargetLsCentralVersion }
    # Optional, uncomment to include:
    #@{ Id = 'bc-web-client'; Version = '' }
)

$Packages | Install-UscPackage -InstanceName $InstanceName -Arguments $Arguments -UpdateInstance