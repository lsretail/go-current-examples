$ErrorActionPreference = 'stop'

Import-Module GoCurrentServer

function New-VsCodePackage
{
    param(
        [Parameter(Mandatory = $true)]
        $Path,
        [Parameter(Mandatory = $true)]
        $OutputDir,
        [switch]$Force
    )

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).ProductVersion.Trim()

    $Package = @{
        Id = 'vs-code'
        Name = 'Microsoft Visual Studio Code'
        Description = 'Code editing. Redefined. Free. Built on open source. Runs everywhere.'
        Version = $Version
        Commands = @{
            Install = 'Package.psm1:Install-Package'
            Remove = 'Package.psm1:Remove-Package'
        }
        Parameters = @(
            @{ Key = 'AddContextMenuFiles'; Description = 'Add "Open With Code" action to Windows Explorer file context menu'; Widget = 'Checkbox'; Default = "true"}
            @{ Key = 'AddContextMenuFolders'; Description = 'Add "Open with Code" action to Windows Explorer directory context menu'; Widget = 'Checkbox'; Default = "true" }
            @{ Key = 'AssociateWithFiles'; Description = 'Register Code as an editor for supported file types'; Widget = 'Checkbox'; Default = "true" }
        )
        InputPath = @(
            Join-Path $PSScriptRoot 'package\*'
            $Path
        )
        OutputDir = $OutputDir
    }
    
    New-GocsPackage @Package -Force:$Force
}

function New-VsCodePackageFromWeb
{
    param(
        [Parameter(Mandatory = $true)]
        $OutputDir,
        $Server,
        $Port,
        [switch] $Force,
        [switch] $Import
    )

    $Uri = 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64'

    $Path = Join-Path $OutputDir 'vscode.exe'
    if ($Force -and (Test-Path $Path))
    {
        Remove-Item $Path
    }
    Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $Path

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).ProductVersion.Trim()
    
    if ($Force -or !(Test-GocsPackage -id 'vs-code' -Version $Version -Server $Server -Port $Port))
    {
        $Package = New-VsCodePackage -Path $Path -OutputDir $OutputDir -Force:$Force
        if ($Import)
        {
            $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
        }
        $Package
    }
}