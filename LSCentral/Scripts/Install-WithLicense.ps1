﻿#requires -RunAsAdministrator
<#
    .SYNOPSIS
        Install the latest LS Central version with specified license.
    
    .NOTES
        Specify a path to your license on line 16, LicenseUri and run the script.
#>
$ErrorActionPreference = 'stop'
Import-Module GoCurrent

$Arguments = @{
    'bc-server' = @{
        AllowSessionCallSuspendWhenWriteTransactionStarted = 'true'
        # Specify your license here and it will be imported during installation:
        LicenseUri = 'c:\path\to\your\license.flf'
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
    @{ Id = 'map/ls-central-to-bc'; Version = '' }
)
 
$Packages | Install-GocPackage -InstanceName 'LSCentral' -Arguments $Arguments