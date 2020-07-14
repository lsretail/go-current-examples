$ErrorActionPreference = 'stop'

Import-Module GoCurrentServer
Import-Module (Join-Path $PSScriptRoot 'Private\Package.psm1')

function New-CertificatePackage
{
    [CmdletBinding(DefaultParameterSetName = 'CertLocationOptional')]
    param(
        [Parameter(Mandatory = $true)]
        $Id,
        [Parameter(Mandatory = $true)]
        $Name,
        [Parameter(Mandatory = $false)]
        $DisplayName,
        [Parameter(Mandatory = $true)]
        $Version,
        [Parameter(Mandatory = $true)]
        $Path,
        [Parameter(Mandatory = $true, ParameterSetName = 'CertLocationSet')]
        $CertStoreLocation,
        [Parameter(Mandatory = $false, ParameterSetName = 'CertLocationOptional')]
        $DefaultCertStoreLocation,
        [Parameter(Mandatory = $false)]
        $DnsIdentity = "",
        [Parameter(Mandatory = $true)]
        $OutputDir,
        [SecureString] $Password,
        [switch] $Private,
        [switch] $Force
    )

    $Resolved = Resolve-Path $Path
    if (@($Resolved).Length -ne 1) 
    {
        throw "Specified path must be a single path, got $(@($Resolved).Length)."
    }
    if ($Private)
    {
        if (!($Resolved.ProviderPath.EndsWith('.pfx')))
        {
            throw "Specified path must have a .pfx extension."
        }
    }
    else 
    {
        if (!($Resolved.ProviderPath.EndsWith('.cer') -or $Resolved.ProviderPath.EndsWith('.cert')))
        {
            throw "Specified path must have a .cer extension."
        }
    }

    $Thumbprint = Get-CertificateThumbprint -Path $Path -Password $Password

    $Package = @{
        Id = $Id
        Name = $Name
        DisplayName = $DisplayName
        Version = $Version
        Commands = @{
            Install = 'Package.psm1:Install-Package'
            Remove = 'Package.psm1:Remove-Package'
        }
        InputPath = @()
        Parameters = @(
            @{ Key = 'CertificateThumbprint'; Description = 'Certificate Thumbprint'; DefaultValue = $Thumbprint; Hidden = $true } 
            @{ Key = 'DnsIdentity'; Description = 'Certificate Identity'; DefaultValue = $DnsIdentity; Hidden = $true } 
        )
        OutputDir = $OutputDir
    }
    $Package.InputPath += $Path

    if ($Private)
    {
        $Package.InputPath += (Join-Path $PSScriptRoot 'Private\*')
        $Package.Parameters += @{ Key = 'User'; Description = 'User'; DefaultValue = '${environment.NetworkServiceUser}' }
    }
    else
    {
        $Package.InputPath += (Join-Path $PSScriptRoot 'Public\*')
    }

    if ($CertStoreLocation)
    {
        $Package.Parameters += @{ Key = 'CertStoreLocation'; Description = 'Certificate Store Location'; DefaultValue = $CertStoreLocation; Hidden = $true }
    }
    else
    {
        if ($DefaultCertStoreLocation)
        {
            $Package.Parameters += @{ Key = 'CertStoreLocation'; Description = 'Certificate Store Location'; DefaultValue = $DefaultCertStoreLocation }
        }
        elseif ($Private)
        {
            $Package.Parameters += @{ Key = 'CertStoreLocation'; Description = 'Certificate Store Location'; DefaultValue = 'cert:\LocalMachine\My' }
        }
        else
        {
            $Package.Parameters += @{ Key = 'CertStoreLocation'; Description = 'Certificate Store Location'; DefaultValue = 'cert:\LocalMachine\Root' }
        }
    }


    if ($Private -and $Password)
    {
        $EncryptedPassword = Get-Encrypted -Password $Password -Key $Id
        $Package.Parameters += @{ Key = 'Password'; Description = 'Password'; DefaultValue = $EncryptedPassword }

        Write-Warning "Specified password will be stored in the package and used during installation."
    }
    
    New-GocsPackage @Package -Force:$Force
}

function Get-Encrypted
{
    param(
        $Key,
        [SecureString] $Password
    )
    $Key = Get-Key -Value $Key
    ConvertFrom-SecureString -SecureString $Password -Key $Key
}

function Get-CertificateThumbprint
{
    param(
        [Parameter(Mandatory = $true)]
        $Path,
        [Parameter(Mandatory = $false)]
        [securestring] $Password
    )

    $Path = Resolve-Path $Path
    $certificateObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $certificateObject.Import($Path, $Password, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet) | Out-Null
    $certificateObject.Thumbprint
}
