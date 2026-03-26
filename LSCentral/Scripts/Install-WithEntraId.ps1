
$ErrorActionPreference = 'stop'


Import-Module UpdateService

$tenantId = '953127b3-4017-4528-b198-551f8e71ebc0' # Your Azure AD tenant ID
$appId = '5c8c57e1-608a-4cdb-87de-564b197ef5f0' # Your Azure AD app registration's application ID
$appIdUrl = "https://LSRetail365.onmicrosoft.com" # The App ID URI you set in your Azure AD app registration, e.g. "https://yourdomain.onmicrosoft.com"

$arguments = @{
	'bc-server' = @{
		ClientServicesCredentialType = 'AccessControlService'
		ValidAudiences = $appId
		ADOpenIdMetadataLocation = "https://login.microsoftonline.com/$tenantId/.well-known/openid-configuration"
		AppIdUri = $appIdUrl
		ServicesCertificateThumbprint = '${my-private-certificate.CertificateThumbprint}'
	}
	'bc-web-client' = @{
		DnsIdentity =  '${my-public-certificate.DnsIdentity}'
		AadApplicationId = $appId
		AadAuthorityUri = "https://login.microsoftonline.com/$tenantId"
	}
}
$packages = @(
    # You can find out how to create the my-public-certificate and
    # my-private-certificate packages in the package examples.
    @{ Id = "my-public-certificate"; Version = "" }
    @{ Id = "my-private-certificate"; Version = "" }

	@{ Id = 'ls-central-demo-database'; VersionQuery = '^-'; }
	@{ Id = 'bc-web-client'; VersionQuery = ''; }
	@{ Id = 'ls-central-app-runtime'; Version = '' }
	@{ Id = 'map/ls-central-to-bc'; Version = '' }
) 

$packages | Install-UscPackage -InstanceName 'LSCentralEntra' -UpdateStrategy 'Manual' -Arguments $arguments