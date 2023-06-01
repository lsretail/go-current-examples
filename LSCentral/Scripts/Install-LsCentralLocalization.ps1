param(
    $LsCentralVersion = '21.5',
    $LocalizationCode = 'DK'
)
$ErrorActionPreference = 'stop'

$Arguments = @{
    'bc-server' = @{
        AllowSessionCallSuspendWhenWriteTransactionStarted = 'true'
    }
    'ls-central-demo-database' = @{
        ConnectionString = 'Data Source=${System.SqlServerInstance};Initial Catalog=${Package.InstanceName};Integrated Security=True'
    }
}

$LocalizationCode = $LocalizationCode.ToUpper()
$LocalizationCodeLower = $LocalizationCode.ToLower()

$Packages = @(
    @{ Id = 'ls-central-demo-database'; VersionQuery = $LsCentralVersion }
    @{ Id = "locale/ls-central-$LocalizationCodeLower-runtime"; VersionQuery = $LsCentralVersion }
    @{ Id = 'bc-web-client'; VersionQuery = ''}
)

$Packages | Install-UscPackage -InstanceName "LSCentral$LocalizationCode" -UpdateStrategy 'Manual' -Arguments $Arguments