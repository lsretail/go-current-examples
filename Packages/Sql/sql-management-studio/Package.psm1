$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    & (Join-Path $Context.TemporaryDirectory SSMS-Setup-ENU.exe) /install /quiet /norestart | Out-Null

    if ($LASTEXITCODE -ne 0)
    {
        throw "Error occurred while installing SQL Server Management Studio."
    }
}