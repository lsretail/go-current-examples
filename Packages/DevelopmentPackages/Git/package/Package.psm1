$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $Path = Join-Path $Context.TemporaryDirectory '*.exe' -Resolve | Select-Object -First 1

    Write-Progress -Id 217 -Activity "Installing Git" -Status "Running installer..." -PercentComplete 20

    if (!$Path)
    {
        throw "No setup file included in package."
    }

    $Output = & $Path /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="ext\shellhere,assoc,assoc_sh" | Out-String
    if ($LASTEXITCODE -ne 0)
    {
        if ($Output)
        {
            Write-Host $Output
        }
        throw "Error occurd while installing Git (exit code $LASTEXITCODE)."
    }
    Write-Progress -Id 217 -Activity "Installing Git" -Status "Done!" -Completed
}

function Remove-Package($Context)
{
    Write-Progress -Id 217 -Activity "Removing Git" -Status "Removing..." -PercentComplete 30
    $UninstObj = Get-UninstallObject -Filter 'Git*' | Where-object { $_.Publisher -like '*The Git Development Community*'}

    if ($UninstObj -and $UninstObj.QuietUninstallString)
    {
        . $UninstObj.UninstallString.Replace('"', '') /VERYSILENT /SP-
    }
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