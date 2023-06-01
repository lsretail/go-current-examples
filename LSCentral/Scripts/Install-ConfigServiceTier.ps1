#requires -RunAsAdministrator
<#
    .SYNOPSIS
        Install LS Central with various settings.
#>
$ErrorActionPreference = 'stop'

$Arguments = @{
    'bc-server' = @{
        ### Package settings:
        # Enable port sharing:
        PortSharing = 'True'
        # Specify a path to license to import on installation:
        LicenseUri = ''
        # Specify true to create a database on installation:
        NewDatabase = 'False'
        # Specifies if installation can or cannot make database change (such 
        # as import license, apps or do platform upgrade):
        NoDatabaseUpgrades = 'False'
        # Specifies if destructive schema synchronization can be forced:
        AllowForceSync = 'false'

        ### Business Central settings:
        AllowSessionCallSuspendWhenWriteTransactionStarted = 'true'
        ServiceUser = '${environment.NetworkServiceUser}'
        ServicePassword = 'dummy'
        ManagementServicesPort = '9045'
        ManagementServicesEnabled = 'True'
        ClientServicesPort = '9046'
        ClientServicesEnabled = 'True'
        SOAPServicesPort = '9047'
        SOAPServicesEnabled = 'True'
        SOAPServicesSSLEnabled = 'False'
        ODataServicesPort = '9048'
        ODataServicesEnabled = 'True'
        ODataServicesSSLEnabled = 'False'
        DeveloperServicesPort = '9049'
        DeveloperServicesEnabled = 'False'
        DeveloperServicesSSLEnabled = 'False'
        PublicWebBaseUrl = ''
        ClientServicesCredentialType = 'Windows'
        ServicesCertificateThumbprint = ''
        ServicesDefaultCompany = ''
        WSFederationLoginEndpoint = ''
        AzureActiveDirectoryClientId = ''
        AzureActiveDirectoryClientSecret = ''
        AppIdUri = ''
        ClientServicesFederationMetadataLocation = ''
        NASServicesStartupCodeunit = ''
        NASServicesStartupMethod = ''
        NASServicesStartupArgument = ''
        # Any additional settings that are not supported as parameters on the 
        # package can be specified as a JSON string with the "SettingsJson" 
        # parameter, as following (CustomSettings.config):
        SettingsJson = (@{
            SqlCommandTimeout = '01:30:00'
            ServicesUseNTLMAuthentication = $true
            ServicesDefaultTimeZone = 'ServicesDefaultTimeZone'
        } | ConvertTo-Json -Compress).ToString()
    }
    'ls-central-demo-database' = @{
        ConnectionString = 'Data Source=${System.SqlServerInstance};Initial Catalog=${Package.InstanceName};Integrated Security=True'
    }
    'bc-web-client' = @{
        ### Package settings
        ContainerSiteName = 'Microsoft Dynamics 365 Business Central Web Client'
        WebServerInstance = '${Package.InstanceName}'
        WebSitePort = '8080'

        ### Business Central settings (navsettings.json)
        ClientServicesCredentialType = 'Windows'
        DnsIdentity = ''
        CertificateThumbprint = ''
        # Any additional settings that are not supported as parameters on the 
        # package can be specified as a JSON string with the "SettingsJson" 
        # parameter, as following (navsettings.json):
        SettingsJson = (@{
            SessionTimeout = '01:30:00'
            AllowNtlm = $true
            Designer = $true
        } | ConvertTo-Json -Compress).ToString()
    }
}

$Packages = @(
    # Uncomment to install SQL Express:
    #@{ Id = 'sql-server-express'; VersionQuery = '^-'}
    @{ Id = 'ls-central-demo-database'; Version = '' }
    @{ Id = 'bc-web-client'; Version = '' }
    @{ Id = 'bc-system-application-runtime'; Version = '' }
    @{ Id = 'bc-base-application-runtime'; Version = '' }
    @{ Id = 'ls-central-app-runtime'; Version = '' }
    @{ Id = 'map/ls-central-to-bc'; Version = '' }
)

$Packages | Install-UscPackage -Arguments $Arguments -InstanceName 'LSCentral'
