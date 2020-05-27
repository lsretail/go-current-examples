#requires -RunAsAdministrator
$ErrorActionPreference = 'stop'
Import-Module GoCurrent

$Arguments = @{
    'bc-server' = @{
        DeveloperServicesEnabled = 'true'
        AllowForceSync = 'true'
    }
}

$Packages = @(
    # Optional, uncomment to include:
    #@{ Id = 'sql-server-express'; VersionQuery = '^-'}
    @{ Id = 'ls-central-demo-database'; VersionQuery = '^'}
    @{ Id = 'ls-central-app'; VersionQuery = '^'}
    @{ Id = 'ls-central-toolbox-server'; VersionQuery = '^'}
    @{ Id = 'ls-dd-server-addin'; VersionQuery = '^'}
    @{ Id = 'bc-system-symbols'; VersionQuery = '^'}
    @{ Id = 'bc-base-application'; VersionQuery = '^'}
    @{ Id = 'bc-web-client'; VersionQuery = ''}
)
 
$Packages | Install-GocPackage -InstanceName 'LSCentral' -Arguments $Arguments