$ErrorActionPreference = 'stop'


function Install-Package($Context)
{
    $SetupExePath = Join-Path $Context.TemporaryDirectory 'setup.exe'
    $LogPath = 'c:\UposSetup.log'
    $IssPath = Resolve-Path (Join-Path $Context.TemporaryDirectory '*.iss') | Select-Object -First 1
    $IssDestPath = 'c:\UposSetup.iss'
    
    Copy-Item $IssPath $IssDestPath -Force
    
    Write-Host "Log file location: $LogPath"
    
    $Arguments = "/s /v`"/qn REBOOT=R /l*vx $LogPath`""
    $Process = Start-Process -FilePath $SetupExePath -ArgumentList $Arguments -PassThru
    $Process.WaitForExit()
    if ($Process.ExitCode -ne 0)
    {
        throw "Tosiba install did not exit correctly, exit code: $($Process.ExitCode)."
    }
}


function Update-Package($Context)
{
    Install-Package -Context $Context
}