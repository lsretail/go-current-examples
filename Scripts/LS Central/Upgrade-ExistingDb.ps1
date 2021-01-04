#requires -RunAsAdministrator
<#
    .SYNOPSIS
        Upgrade existing database with new versions of Business Central and LS Central.
    
    .DESCRIPTION
        This is an example of how you can use Go Current to upgrade your 
        existing database, with a new Business Central platform, apps and 
        LS Central. You can extend this with your own apps as well.

        You must have a database is place on a SQL server, then use this 
        script to install a new service tier / NST, with the target 
        BC platform version and with selected apps.

        Requirements for the existing databases:
        * Is running LS Central/Business Central 15.0 or above.
        * Database's platform version is the same or earlier version than the POS bundle will install.
        * All apps in the existing database are of the same version or earlier than listed in this script.

        Steps:

        1. Either:
            * Restore a database backup on your SQL server.
            * Backup existing database before running the upgrade, Go Current will not create a backup.
        2. Adjust the parameters:
            * ConnectionString: Connection string for your database.
            * LsCentralVersion: Your target LS Central version.
            * BcAppVersion: Your target Business Central (app) version.
            * InstanceName: Name for your GoC instance and service tier created.
            * LicensePath: Optional, path to a new license file (.flf).
            (See note below)
        3. Run script.

        NOTE: If you are upgrading from a version earlier then 17.0.0, you must allow force schema changes.
              See comment below for further instructions.
#>

param(
    $ConnectionString = "Data Source=LOCALHOST;Initial Catalog=YOUR-DB;Integrated Security=True",
    $LsCentralVersion = '17.1',
    $BcAppVersion = '17.1',
    $InstanceName = 'Upgrade',
    $LicensePath
)

Import-Module GoCurrent

$Arguments = @{
    'bc-server' = @{
        ConnectionString = $ConnectionString
        AllowSessionCallSuspendWhenWriteTransactionStarted = 'true'
        LicenseUri = $LicensePath
    }
    # Uncomment if you are upgrading from version earlier then 17.0.0.
    #'ls-central-app-runtime' = @{
    #    AllowForceSync = 'true'
    #}
}

$Packages = @(
    @{ Id = 'bc-system-symbols'; Version = '' }
    @{ Id = 'bc-system-application-runtime'; Version = $BcAppVersion }
    @{ Id = 'bc-base-application-runtime'; Version = $BcAppVersion }
    @{ Id = 'map/bc-app-to-platform'; Version = $BcAppVersion }
    @{ Id = 'ls-central-app-runtime'; Version = $LsCentralVersion }
    # Optional, uncomment to include:
    #@{ Id = 'bc-web-client'; Version = '' }
)

$Packages | Install-GocPackage -InstanceName $InstanceName -Arguments $Arguments