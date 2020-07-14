$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $Activity = "Import public certificate"
    Write-Progress -Id 217 -Activity $Activity -Status 'Importing certificate' -PercentComplete 20
    $Path = Resolve-Path (Join-Path $Context.TemporaryDirectory '*.cer')
    if (!$Path)
    {
        $Path = Resolve-Path (Join-Path $Context.TemporaryDirectory '*.cert')
    }
    if (!$Path)
    {
        throw "No certificate is included in the package."
    }

    Import-Certificate -FilePath $Path -CertStoreLocation $Context.Arguments.CertStoreLocation
    Write-Progress -Id 217 -Activity $Activity -Status 'Done' -PercentComplete 100
}

function Remove-Package($Context)
{
    Remove-Item -Path (Join-Path $Context.Arguments.CertStoreLocation $Context.Arguments.CertificateThumbprint)
}