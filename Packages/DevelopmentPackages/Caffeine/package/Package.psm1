$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $Path = Join-Path $Context.TemporaryDirectory 'caffeine64.exe'    
    if (!(Test-Path $Path))
    {
        throw "Could not locate caffeine64.exe"
    }

    $DestPath = Join-Path ([Environment]::GetFolderPath('Startup')) 'caffeine64.exe'
    Copy-Item $Path $DestPath -Force
    & $DestPath
}

function Remove-Package($Context)
{
    $Path = Join-Path ([Environment]::GetFolderPath('Startup')) 'caffeine64.exe'

    Stop-ProcessByPath -Path $Path

    Remove-Item $Path -Force -ErrorAction Continue
}

function Stop-ProcessByPath
{
    param(
        [Array] $Path
    )
    $Paths = Resolve-Path $Path -ErrorAction SilentlyContinue | ForEach-Object { $_.ProviderPath }
    foreach ($Process in Get-Process)
    {
        if ($Process.Path -iin $Paths)
        {
            try {
                $Process.Kill()    
            }
            catch {
                # There might be a "Access denied" error because the process already stopped.
                Write-Warning "Could not kill process by path $Path."
            }
            
        }
    }
}