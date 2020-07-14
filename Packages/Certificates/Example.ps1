param(
    $OutputDir = (Join-Path $PSScriptRoot 'OutputDir'),
    $Server,
    $Port,
    [switch] $Import,
    [switch] $Force
)

Import-Module (Join-Path $PSScriptRoot 'NewCertificatePackages.psm1') -Force

# Password for private certificate.
$Password = ConvertTo-SecureString -String "MyPassword" -Force -AsPlainText

# Create output directory for certificates and packages.
[System.IO.Directory]::CreateDirectory($OutputDir) | Out-Null

# Create new self signed certificate.
$Arguments = @{
    Type = 'SSLServerAuthentication'
    DnsName = "localhost"
    CertStoreLocation = 'cert:\LocalMachine\My'
    KeyUsageProperty = 'All'
    KeySpec = 'KeyExchange'
    FriendlyName = 'My Self Signed Certificate'
    NotAfter = (Get-Date -Year 2037 -Month 10 -Day 10)
    NotBefore = (Get-Date -Year 2010 -Month 10 -Day 10)
}
$Certificate = New-SelfSignedCertificate @Arguments

# Export the certificates.
Export-Certificate -FilePath (Join-Path $OutputDir 'Public.cer') -Cert $Certificate | Out-Null
Export-PfxCertificate -FilePath (Join-Path $OutputDir 'Private.pfx') -Cert $Certificate -Password $Password | Out-Null

Remove-Item -Path "cert:\LocalMachine\My\$($Certificate.Thumbprint)"

# New public certificate package.
$Arguments = @{
    Id = 'my-public-certificate' 
    Name  ='My Public Certificate' 
    Version = '1.0.0' 
    Path = (Join-Path $OutputDir 'Public.cer')
    CertStoreLocation = 'cert:\LocalMachine\Root' 
    OutputDir = $OutputDir
    Private = $false
}
$Package = New-CertificatePackage @Arguments -Force:$Force
$Package
if ($Import)
{
    $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
}

# New private certificate package.
$Arguments = @{
    Id = 'my-private-certificate'
    Name  ='Test Private Certificate' 
    Version = '1.0.0' 
    Path = (Join-Path $OutputDir 'Private.pfx')
    CertStoreLocation = 'cert:\LocalMachine\My' 
    OutputDir = $OutputDir
    Private = $true
    Password = $Password
}
$Package = New-CertificatePackage @Arguments -Force:$Force
if ($Import)
{
    $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
}