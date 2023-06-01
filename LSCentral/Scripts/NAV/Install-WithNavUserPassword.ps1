$ErrorActionPreference = 'stop'

$InstanceName = 'LSCentral14'
$UserName = 'admin'
$Password =  ConvertTo-SecureString "MyP@ssw0rd" -AsPlainText -Force

$Arguments = @{
    'bc-server' = @{
        DeveloperServicesEnabled = 'true'
        ClientServicesCredentialType = 'NavUserPassword'
        ServicesCertificateThumbprint = '${my-private-certificate.CertificateThumbprint}'
        AllowSessionCallSuspendWhenWriteTransactionStarted = 'true'
    }
    'bc-web-client' = @{
        DnsIdentity =  '${my-public-certificate.DnsIdentity}'
    }
    'bc-windows-client' = @{
        DnsIdentity =  '${my-public-certificate.DnsIdentity}'
    }
}

$LsCentralVersion = '14.01'
$BcVersion = (Get-UscUpdates -Id 'ls-central-objects' -Version $LsCentralVersion | Where-Object { $_.Id -eq 'bc-server'}).Version

$Packages = @(
    # Optional, uncomment to include:
    #@{ Id = 'sql-server-express'; VersionQuery = '^-'}
    #@{ Id = 'bc-windows-client'; VersionQuery = ''}
    @{ Id = "my-private-certificate"; Version = "" }
    @{ Id = "my-public-certificate"; Version = "" }

    @{ Id = 'ls-central-demo-database'; VersionQuery = $LsCentralVersion}
    @{ Id = 'bc-server'; VersionQuery = $BcVersion}
    @{ Id = 'ls-central-toolbox-server'; VersionQuery = $LsCentralVersion}
    @{ Id = 'ls-central-toolbox-client'; VersionQuery = $LsCentralVersion}
    @{ Id = 'bc-web-client'; VersionQuery = ''}
)
 
$Packages | Install-UscPackage -InstanceName $InstanceName -UpdateStrategy 'Manual' -Arguments $Arguments -UpdateInstance

# Create NAV user:

$Installed = Get-UscInstalledPackage -Id 'bc-server' -InstanceName $InstanceName

$ServerInstance = $Installed.Info.ServerInstance

Import-Module (Join-Path $Installed.Info.ServerDir 'Microsoft.Dynamics.Nav.Management.dll')

New-NAVServerUser -ServerInstance $ServerInstance -UserName $UserName -Password $Password
$User = Get-NAVServerUser -ServerInstance $ServerInstance | Where-Object { $_.UserName -eq $UserName.ToUpper() }
New-NAVServerUserPermissionSet $ServerInstance -UserName $User.UserName -PermissionSetId SUPER