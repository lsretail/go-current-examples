$ErrorActionPreference = 'stop'

Import-Module GoCurrentServer

function New-GitPackage
{
    param(
        [Parameter(Mandatory = $true)]
        $Path,
        [Parameter(Mandatory = $true)]
        $OutputDir,
        [switch] $Force
    )

    $Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).ProductVersion.Trim()

    $Package = @{
        Id = 'git'
        Name = 'Git'
        Description = 'Git is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency.'
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

function New-GitPackageFromWeb
{
    param(
        $Server,
        $Port,
        [Parameter(Mandatory = $true)]
        $OutputDir,
        [Switch] $Import,
        [switch] $Force
    )

    $Content = Invoke-WebRequest -UseBasicParsing -Uri 'https://git-scm.com/download/win'

    $PackageId = 'git'

    $UriForm = 'https://github.com/git-for-windows/git/releases/download/vXXXXX.windows.XXXXX/Git-XXXXX-64-bit.exe'
    $UriForm = [Regex]::Escape($UriForm)
    $UriForm = $UriForm.Replace('XXXXX', '[\d\.]*')
    $Pattern = [Regex]::new($UriForm)

    $Match = $Pattern.Match($Content.RawContent)

    if ($Match.Success)
    {
        $Url = $Match.Value
        $Match = [Regex]::new('\d+\.\d+\.\d+(\.\d+)?').Match($Url)
        if ($Match.Success)
        {
            if ($Force -or !(Test-GocsPackage -Id $PackageId -Version $Match.Value -Server $Server -Port $Port))
            {
                [System.IO.Directory]::CreateDirectory($OutputDir) | Out-Null
                $OutputFilePath = Join-Path $OutputDir 'Git.exe'
                Invoke-WebRequest -Uri $Url -OutFile $OutputFilePath
                $Package = New-GitPackage -Path $OutputFilePath -OutputDir $OutputDir -Force:$Force
                if ($Import)
                {
                    $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
                }
                $Package
            }
        }
        else {
            throw "Could not find version number."
        }
    }
    else
    {
        throw "Could not find download link."
    }
}
