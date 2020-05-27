#requires -RunAsAdministrator
<#
    .SYNOPSIS
        Install a service tier and create an empty database in the process.
#>
$ErrorActionPreference = 'stop'
Import-Module GoCurrent

$Arguments = @{
    'bc-server' = @{
        NewDatabase = 'true'
    }
}

Install-GocPackage -Id 'bc-server' -Arguments $Arguments