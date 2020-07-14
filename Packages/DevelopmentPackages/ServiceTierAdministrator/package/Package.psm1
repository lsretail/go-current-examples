$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $Path = Join-Path $Context.TemporaryDirectory '*.exe' -Resolve | Select-Object -First 1

    Write-Progress -Id 217 -Activity "Installing Service Tier Administration Tool" -Status "Running installer..." -PercentComplete 20

    if (!$Path)
    {
        throw "No setup file included in package."
    }

    $Output = & $Path /VERYSILENT | Out-String
    if ($LASTEXITCODE -ne 0)
    {
        if ($Output)
        {
            Write-Host $Output
        }
        throw "Error occurd while installing Service Tier Administration Tool (exit code $LASTEXITCODE)."
    }

    Write-Progress -Id 217 -Activity "Installing Service Tier Administration Tool" -Status "Done!" -Completed
}

function Remove-Package($Context)
{
    Write-Progress -Id 217 -Activity "Removing Service Tier Administration Tool" -Status "Removing..."
    $UninstObj = Get-UninstallObject -Filter '*ServiceTierAdministration*'

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