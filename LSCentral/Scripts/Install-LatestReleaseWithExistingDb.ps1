#requires -RunAsAdministrator
<#
    .SYNOPSIS
        Install the latest LS Central release on top of existing database.

    .PARAMETER ConnectionString
        Specifies a connection string for existing database.
    
    .PARAMETER ServiceUser
        Specifies a Windows users that run the Business Central service.
        The user must have access and db_owner permissions to the existing database.

    .PARAMETER ServicePassword
        Specifies the password for the service user.

    .EXAMPLE
        ```powershell
        Install-LatestRelease.ps1 -ConnectionString 'Data Source=SQLSERVERMACHINE;Initial Catalog=DATABASENAME;Integrated Security=True' -ServiceUser 'domain\user' -ServicePassword (ConvertTo-SecureString -String 'DummyPassword' -AsPlainText -Force)
        ```
        This example installs lastest version fo LS Central, connects the database DATABASENAME on the server SQLSERVERMACHINE.
        With the user domain\user running the Business Central service tier.

#>
param(
    $ConnectionString = 'Data Source=${System.SqlServerInstance};Initial Catalog=${Package.InstanceName};Integrated Security=True',
    [Parameter(Mandatory)]
    $ServiceUser,
    [Parameter(Mandatory)]
    [SecureString] $ServicePassword,
    $InstanceName = 'LSCentral'
)
$ErrorActionPreference = 'stop'

$Arguments = @{
    'bc-server' = @{
        ConnectionString = $ConnectionString
        AllowSessionCallSuspendWhenWriteTransactionStarted = 'true'
        ServiceUser = $ServiceUser
        ServicePassword = (ConvertFrom-SecureString $ServicePassword).ToString()
    }
}

$Packages = @(
    @{ Id = 'bc-server'; Version = '' }
    @{ Id = 'bc-web-client'; Version = '' }
    @{ Id = 'bc-system-symbols'; Version = '' }
    @{ Id = 'bc-system-application-runtime'; Version = '' }
    @{ Id = 'bc-base-application-runtime'; Version = '' }
    @{ Id = 'ls-central-app-runtime'; Version = '' }
    @{ Id = 'map/ls-central-to-bc'; Version = '' }
)
 
$Packages | Install-UscPackage -InstanceName $InstanceName -Arguments $Arguments