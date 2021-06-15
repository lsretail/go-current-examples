$ErrorActionPreference = 'stop'
Import-Module GoCurrent

$Arguments = @{
    'bc-server' = @{
        AllowForceSync = 'true'
        AllowSessionCallSuspendWhenWriteTransactionStarted = 'true'
    }
    'ls-central-demo-database' = @{
        ConnectionString = 'Data Source=${System.SqlServerInstance};Initial Catalog=${Package.InstanceName};Integrated Security=True'
    }
}

$LsVersion = '17.1'
$LocalizationCode = 'DK'.ToUpper()
$LocalizationCodeLower = $LocalizationCode.ToLower()

$Packages = @(
    @{ Id = 'ls-central-demo-database'; VersionQuery = $LsVersion }

    @{ Id = 'bc-system-symbols'; VersionQuery = '^'}
    @{ Id = "bc-base-application-$LocalizationCodeLower"; VersionQuery = '^'}

    @{ Id = 'ls-central-app'; VersionQuery = $LsVersion }

    @{ Id = "ls-central-app-$LocalizationCodeLower"; VersionQuery = $LsVersion }

    @{ Id = 'ls-central-toolbox-server'; VersionQuery = $LsVersion }
    @{ Id = 'map/ls-central-to-bc'; VersionQuery = $LsVersion }

    @{ Id = 'bc-web-client'; VersionQuery = ''}
    @{ Id = 'dev/ls-central-setup-script'; VersionQuery = ''}
)
 
# View what packages will be installed:
# $Packages | Get-GocUpdates

$Packages | Install-GocPackage -InstanceName "LSCentral$LocalizationCode" -UpdateStrategy 'Manual' -Arguments $Arguments