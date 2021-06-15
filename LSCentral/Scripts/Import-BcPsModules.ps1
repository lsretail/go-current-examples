<#
    .SYNOPSIS
        Import Business Central PowerShell modules from instance name.

    .DESCRIPTION
        This example imports the Business Central PowerShell modules for 
        the specified instance name.

    .PARAMETER InstanceName
        Name of existing instance in Go Current.

    .EXAMPLE
        PS> .\Import-BcModules.ps1 -InstanceName 'LsCentral'

        This example imports the BC cmdlets from a Go Current instance called LsCentral.
#>
param(
    $InstanceName = 'LsCentral'
)
$ErrorActionPreference = 'stop'

# Get install details about the bc-server package for a particular instance:
$BcServer = Get-GocInstalledPackage -Id 'bc-server' -InstanceName $InstanceName

if (!$BcServer)
{
    throw "Specified instance ($InstanceName) does not exists or is not a Business Central instance."
}

# Import PowerShell Modules into session:
Import-Module (Join-Path $BcServer.Info.ServerDir 'Microsoft.Dynamics.Nav.Management.dll') -Global
Import-Module (Join-Path $BcServer.Info.ServerDir 'Microsoft.Dynamics.Nav.Apps.Management.dll') -Global