$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $Path = (Join-Path $PSScriptRoot '*.exe' -Resolve | Select-Object -First 1)
    $Process = Start-Process -FilePath $Path -ArgumentList '/S' -PassThru
    $Process.WaitForExit()
    if ($Process.ExitCode -ne 0)
    {
        throw "Installation failed with exit code $($Process.ExitCode)."
    }
}

function Remove-Package($Context)
{
    $Object = Get-UninstallObject -Filter '7-Zip*'
    if ($Object.UninstallString)
    {
        & $Object.UninstallString '/S'

        if ($LASTEXITCODE -ne 0)
        {
            Write-Warning 'Error occured while uninstalling 7-zip'
        }
    }
}

function Get-UninstallObject
{
    <#
    .SYNOPSIS
        Get uninstall object from registry by program name.
    
    .PARAMETER ProgramName
        Name of program.
    #>

    param(
        [Parameter(Mandatory = $true)]
        [Alias('ProgramName')]
        [string] $Filter
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
            if($DisplayName -ilike "$Filter")
            {
                $Object = Get-ItemProperty "Registry::$Registry\$ThisKey"
                $Object
            }
        }
    }
}