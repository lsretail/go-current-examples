param(
    $Server = 'localhost',
    $RestManagementPort = '16551'
)
#requires -RunAsAdministrator

<#
    .SYNOPSIS
        Install requirements for build.
#>

$ErrorActionPreference = 'stop'

$env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath","Machine")
try
{
    Import-Module GoCurrent
}
catch
{
    Invoke-WebRequest -Uri "http://$($Server):$($RestManagementPort)/ManagementFile/install" -UseBasicParsing | % { & ([ScriptBlock]::Create([System.Text.Encoding]::Utf8.GetString($_.Content))) }
    Import-Module GoCurrent
}

$Arguments = @{
    'go-current-server' = @{
        'ConnectionString' = ''
    }
}

$Packages = @(
    @{ Id = 'ls-setup-helper'; Version = '^!'}
    @{ Id = 'ls-package-tools'; Version = '^!'}
    @{ Id = 'go-current-server'; Version = '^!'}
)

if (($Packages | Get-GocUpdates))
{
    Write-Host "Installing requirements for build..."
    $Packages | Install-GocPackage -UpdateStrategy Automatic -Arguments $Arguments
    $env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath","Machine")
}

Write-Host 'Current installed packages:'
$Packages | Get-GocInstalledPackage | Format-Table -Property 'Id', 'Version' | Out-String | Write-Host