<#
    .SYNOPSIS
        Import Business Central PowerShell modules from instance name.

    .DESCRIPTION
        This example imports the Business Central PowerShell modules for
        the specified instance name.

    .PARAMETER InstanceName
        Name of existing instance in Update Service.

    .EXAMPLE
        PS> .\Import-BcModules.ps1 -InstanceName 'LsCentral'

        This example imports the BC cmdlets from a Update Service instance called LsCentral.
#>
param(
    $InstanceName = 'LsCentral'
)
$ErrorActionPreference = 'stop'

Import-Module LsSetupHelper\BusinessCentral\Management

Import-Module (Get-BcModulePath -InstanceName $InstanceName -Type Management) -Global
Import-Module (Get-BcModulePath -InstanceName $InstanceName -Type Apps) -Global