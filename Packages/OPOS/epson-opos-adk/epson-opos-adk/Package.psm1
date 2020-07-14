$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $SetupFile = Join-Path $Context.TemporaryDirectory 'setup.iss'
    $RegFile = Join-Path $Context.TemporaryDirectory 'OposData.reg'
    $SetupExe = Join-Path $Context.TemporaryDirectory 'setup.exe'

    $Arguments = "/s /f1`"$SetupFile`" /a`"$RegFile`""
    $Process = Start-Process -FilePath $SetupExe -ArgumentList $Arguments -PassThru
    $Process.WaitForExit()
    if ($Process.ExitCode -ne 0)
    {
        throw "Epson install did not exit correctly, exit code: $($Process.ExitCode)."
    }
}

function Update-Package($Context)
{
    Install-Package -Context $Context
}