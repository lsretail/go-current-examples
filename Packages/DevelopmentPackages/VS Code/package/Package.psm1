$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    Write-Progress -Id 217 -Activity "Installing VS Code" -Status "Running installer..."
    $Tasks = @('quicklaunchicon', 'addtopath')
    if ($Context.Arguments.AssociateWithFiles)
    {
        $Tasks += 'AssociateWithFiles'
    }
    if ($Context.Arguments.AddContextMenuFolders)
    {
        $Tasks += 'AddContextMenuFolders'
    }
    if ($Context.Arguments.AddContextMenuFiles)
    {
        $Tasks += 'AddContextMenuFiles'
    }

    $TasksString = $Tasks -join ','

    $LogPath = Join-Path $Context.TemporaryDirectory 'log.txt'
    
    & (Join-Path $Context.TemporaryDirectory 'vscode.exe') /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /MERGETASKS=!runcode "/TASKS=$TasksString" /log="$LogPath" | Out-String
    if ($LASTEXITCODE -ne 0)
    {
        if (Test-Path $LogPath)
        {
            Write-Host (Get-Content -Path $LogPath -Raw)
        }
        throw "Error occurred while installing VS Code (exit code $LastExitCode)."
    }
    Write-Progress -Id 217 -Activity "Installing VS Code" -Status "Done!"
}

function Remove-Package($Context)
{
    $UninstObj = Get-UninstallObject -Filter '*Microsoft Visual Studio Code'

    $LogPath = Join-Path $Context.TemporaryDirectory 'log.txt'
    & $UninstObj.UninstallString.Replace('"', '') /VERYSILENT /SUPPRESSMSGBOXES /SP- /log="$LogPath" | Out-String
    if ($LASTEXITCODE -ne 0)
    {
        if (Test-Path $LogPath)
        {
            Write-Host (Get-Content -Path $LogPath -Raw)
        }
        throw "Error occurred while removing VS Code (exit code $LastExitCode)."
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

