#requires -RunAsAdministrator
<#
    .SYNOPSIS
        Install LS Central with NavUserPassword and necessary certificate.
    
    .DESCRIPTION
        This will install LS Central configured to use NavUserPassword and installs
        self-signed certificates. 

        The certificate packages can be created by running the script:

        PS C:\> & ..\Packages\Certificates\Example.ps1 -Import

        The script will create self-signed certificates.
#>
$ErrorActionPreference = 'stop'
Import-Module GoCurrent
$Arguments = @{
    'bc-server' = @{
        DeveloperServicesEnabled = 'true'
        AllowForceSync = 'true'
        ClientServicesCredentialType = 'NavUserPassword'
        ServicesCertificateThumbprint = '${my-private-certificate.CertificateThumbprint}'
    }
    'bc-web-client' = @{
        DnsIdentity =  '${my-public-certificate.DnsIdentity}'
    }
}
$Packages = @(
    # Optional, uncomment to include:
    #@{ Id = 'sql-server-express'; VersionQuery = '^-'}

    # You can find out how to create the my-public-certificate and
    # my-private-certificate packages in the package examples.
    @{ Id = "my-public-certificate"; Version = "" }
    @{ Id = "my-private-certificate"; Version = "" }

    @{ Id = 'ls-central-demo-database'; VersionQuery = '^'}
    @{ Id = 'ls-central-app'; VersionQuery = '^'}
    @{ Id = 'ls-central-toolbox-server'; VersionQuery = '^'}
    @{ Id = 'ls-dd-server-addin'; VersionQuery = '^'}
    @{ Id = 'bc-system-symbols'; VersionQuery = '^'}
    @{ Id = 'bc-base-application'; VersionQuery = '^'}
    @{ Id = 'bc-web-client'; VersionQuery = ''}
)
 
$Packages | Install-GocPackage -InstanceName 'LSCentral' -UpdateStrategy 'Manual' -Arguments $Arguments