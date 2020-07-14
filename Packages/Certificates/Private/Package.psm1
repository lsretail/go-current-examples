$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $Activity = "Import private certificate"
    Write-Progress -Id 217 -Activity $Activity -Status 'Importing certificate' -PercentComplete 20
    $Path = Resolve-Path (Join-Path $Context.TemporaryDirectory '*.pfx')
    
    if (!$Path)
    {
        throw "No certificate is included in the package."
    }

    if ($Context.Arguments.Password)
    {
        $Password = ConvertTo-SecureString -String $Context.Arguments.Password -Key (Get-Key -Value $Context.Id)
    }
    
    Import-PfxCertificate -FilePath $Path -CertStoreLocation $Context.Arguments.CertStoreLocation -Password $Password
    if ($Context.Arguments.User)
    {
        Grant-User -CertStoreLocation $Context.Arguments.CertStoreLocation -Thumbprint $Context.Arguments.CertificateThumbprint -User $Context.Arguments.User
    }
    Write-Progress -Id 217 -Activity $Activity -Status 'Done' -PercentComplete 100 
}

function Get-Key
{
    param(
        $Value
    )

    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Value)
    $Sha1 = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider
    $Sha1.ComputeHash($Bytes) | Select-Object -First 16
}

function Get-Decrypted
{
    param(
        $Key,
        [string] $String
    )

    ConvertTo-SecureString -String $SecureString -Key $Key
}

function Grant-User
{
    param(
        $CertStoreLocation,
        $Thumbprint,
        $User
    )
    if (!$User)
    {
        return
    }
    $Path = Join-Path $CertStoreLocation $Thumbprint

    $Certificate = Get-ChildItem $Path
    
    $FilePath = Join-Path "C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys\" $Certificate.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName

    $Acl = Get-Acl -Path $FilePath
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($User, 'Read', 'None', "None", 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl $FilePath $Acl | Out-Null
}

function Remove-Package($Context)
{
    Remove-Item -Path (Join-Path $Context.Arguments.CertStoreLocation $Context.Arguments.CertificateThumbprint)
}