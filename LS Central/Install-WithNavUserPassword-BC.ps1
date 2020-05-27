$ErrorActionPreference = 'stop'
Import-Module GoCurrent
$Arguments = @{
    'bc-server' = @{
        DeveloperServicesEnabled = 'true'
        AllowForceSync = 'true'
        ClientServicesCredentialType = 'NavUserPassword'
        ServicesCertificateThumbprint = '${internal/self-signed-certificate-private.CertificateThumbprint}'
    }
    'bc-web-client' = @{
        DnsIdentity =  '${internal/self-signed-certificate-public.DnsIdentity}'
    }
}
$Packages = @(
    # Optional, uncomment to include:
    #@{ Id = 'sql-server-express'; VersionQuery = '^-'}
    @{ Id = "internal/self-signed-certificate-private"; Version = "" }
    @{ Id = "internal/self-signed-certificate-public"; Version = "" }

    @{ Id = 'ls-central-demo-database'; VersionQuery = '^'}
    @{ Id = 'ls-central-app'; VersionQuery = '^'}
    @{ Id = 'ls-central-toolbox-server'; VersionQuery = '^'}
    @{ Id = 'ls-dd-server-addin'; VersionQuery = '^'}
    @{ Id = 'bc-system-symbols'; VersionQuery = '^'}
    @{ Id = 'bc-base-application'; VersionQuery = '^'}
    @{ Id = 'bc-web-client'; VersionQuery = ''}
)
 
$Packages | Install-GocPackage -InstanceName 'LSHotelsMaster' -UpdateStrategy 'Manual' -Arguments $Arguments