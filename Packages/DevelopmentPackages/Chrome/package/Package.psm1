$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    Write-Progress -Id 217 -Activity "Installing Chrome" -Status "Running installer..." -PercentComplete 20
    $Path = Join-Path $Context.TemporaryDirectory '*.exe' -Resolve | Select-Object -First 1

    $Output = & $Path /silent /install | Out-String
    if ($LASTEXITCODE -ne 0)
    {
        if ($Output)
        {
            Write-Warning $Output
        }
        throw "Error installing Chrome, exitcode: $LASTEXITCODE"
    }
    Write-Progress -Id 217 -Activity "Installing Chrome" -Status "Done!" -Completed
}

function Remove-Package($Context)
{
    Write-Progress -Id 217 -Activity "Uninstalling Chrome" -Status "Removing..."
    $UninstObj = Get-UninstallObject -Filter '*Chrome*' #| Where-object { $_.Publisher -like '*The Git Development Community*'}
    $UninstallString = "$($UninstObj.UninstallString) --force-uninstall"
    
    $Split = $UninstallString.Split('"')
    $Exe = $Split[1]
    $Arguments = $Split[2].Split(' ')
    
    $Arguments = $Arguments | Where-Object { $_ -inotin @('', $null)}
    
    $Process = Start-Process -FilePath $Exe -ArgumentList $Arguments -Wait -PassThru
    
    if ($Process.ExitCode -ne 0)
    {
        Write-Warning "Error uninstalling Chrome, exit code: $($Process.ExitCode)"
    }
    Write-Progress -Id 217 -Activity "Uninstalling Chrome" -Status "Done!"
}

function Get-UninstallObject()
{
    <#
    .SYNOPSIS
        Get uninstall object from registry by program name.
    
    .PARAMETER ProgramName
        Name of program.
    #>

    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Filter
    )
    $UninstallKeyes = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    $Registry = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Registry64')

    $SubKeys = @()
    foreach ($UninstallKey in $UninstallKeyes)
    {
        $RegKey = $Registry.OpenSubKey($UninstallKey)
        $SubKeys = $RegKey.GetSubKeyNames()

        foreach($Key in $SubKeys)
        {
            $ThisKey = $UninstallKey + "\" + $Key
            $ThisSubKey = $Registry.OpenSubKey($Thiskey)
            $DisplayName = $ThisSubKey.GetValue("DisplayName")
            if($DisplayName -like "$Filter")
            {
                $Object = Get-ItemProperty "Registry::$Registry\$ThisKey"
                $Object
            }
        }

    }    
}