$ErrorActionPreference  = 'stop'

function New-CaffeinePackageFromWeb
{
    param(
        $Server,
        $Port,
        $OutputDir,
        [Switch] $Import,
        [switch] $Force
    )

    $Uri = 'https://www.zhornsoftware.co.uk/caffeine/caffeine.zip'
    $ZipPath = Join-Path $OutputDir 'caffeine.zip'

    if (!$Force -and (Test-Path $Path))
    {
        throw "File already exists $Path"
    }

    Invoke-WebRequest -UseBasicParsing -OutFile $ZipPath -Uri $Uri

    $TempDir = Join-Path $OutputDir ([System.IO.Path]::GetRandomFileName())
    [System.IO.Directory]::CreateDirectory($TempDir) | Out-Null

    Expand-Archive -Path $ZipPath -DestinationPath $TempDir
    $Path = Join-Path $TempDir 'caffeine64.exe'

    if (!(Test-Path $Path))
    {
        throw "Could not locate caffeine64.exe"
    }

    try
    {
        $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).FileVersionRaw.ToString()
        $Version = Format-Version -Version $Version -Places 3
    
        if ($Force -or !(Test-GocsPackage -id 'caffeine' -Version $Version -Server $Server -Port $Port))
        {
            $Package = New-CaffeinePackage -Path $Path -OutputDir $OutputDir -Force:$Force
            if ($Import)
            {
                $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
            }
            $Package
        }
    }
    finally
    {
        Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function New-CaffeinePackage
{
    param(
        [Parameter(Mandatory = $true)]
        $Path,
        [Parameter(Mandatory = $true)]
        $OutputDir,
        [switch]$Force
    )

    Import-Module LsSetupHelper\Release\Version

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).FileVersionRaw.ToString()
    $Version = Format-Version -Version $Version -Places 3 -DotNetFormat

    $Package = @{
        Id = 'caffeine'
        Name = 'Caffeine'
        Description = 'Prevent your computer from going to sleep.'
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