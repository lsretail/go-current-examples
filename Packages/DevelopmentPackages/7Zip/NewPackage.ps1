$ErrorActionPreference  = 'stop'

function New-7ZipPackageFromWeb
{
    param(
        $Server,
        $Port,
        $OutputDir,
        $Uri = 'https://www.7-zip.org/a/7z1900-x64.exe',
        [Switch] $Import,
        [switch] $Force
    )

    
    $Path = Join-Path $OutputDir '7z-x64.exe'

    if (!$Force -and (Test-Path $Path))
    {
        throw "File already exists $Path"
    }

    Invoke-WebRequest -UseBasicParsing -OutFile $Path -Uri $Uri

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).ProductVersion.Trim()
    $Version = Format-Version -Version $Version -Places 3
    
    if ($Force -or !(Test-GocsPackage -id '7-zip' -Version $Version -Server $Server -Port $Port))
    {
        $Package = New-7ZipPackage -Path $Path -OutputDir $OutputDir -Force:$Force
        if ($Import)
        {
            $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
        }
        $Package
    }
}

function New-7ZipPackage
{
    param(
        [Parameter(Mandatory = $true)]
        $Path,
        [Parameter(Mandatory = $true)]
        $OutputDir,
        [switch]$Force
    )

    Import-Module LsSetupHelper\Release\Version

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).ProductVersion.Trim()
    $Version = Format-Version -Version $Version -Places 3 -DotNetFormat

    $Package = @{
        Id = '7-zip'
        Name = '7-Zip'
        Description = '7-Zip is a file archiver with a high compression ratio.'
        Version = $Version
        Commands = @{
            Install = 'Package.psm1:Install-Package'
            Update = 'Package.psm1:Install-Package'
            Remove = 'Package.psm1:Remove-Package'
        }
        InputPath = @(
            Join-Path $PSScriptRoot 'package\*'
            $Path
        )
        OutputDir = $OutputDir
    }
    
    New-GocsPackage @Package -Force:$Force
}