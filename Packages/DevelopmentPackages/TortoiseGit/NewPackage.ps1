$ErrorActionPreference = 'stop'

Import-Module GoCurrentServer
Import-Module (Join-Path $PSScriptRoot '..\..\Msi\MsiPackage.psm1')

function New-TortoiseGitPackageFromWeb
{
    param(
        $Server,
        $Port,
        $OutputDir,
        [Switch] $Import,
        [switch] $Force
    )

    $Content = Invoke-WebRequest -UseBasicParsing -Uri 'https://tortoisegit.org/download/'

    $PackageId = 'tortoise-git'

    $UriForm = '//download.tortoisegit.org/tgit/XXXXX/TortoiseGit-XXXXX-64bit.msi'
    $UriForm = [Regex]::Escape($UriForm)
    $UriForm = $UriForm.Replace('XXXXX', '[\d\.]*')
    $Pattern = [Regex]::new($UriForm)

    $Match = $Pattern.Match($Content.RawContent)

    if ($Match.Success)
    {
        $Url = 'https:' + $Match.Value
        $Match = [Regex]::new('\d+\.\d+\.\d+\.\d+').Match($Url)
        if ($Match.Success)
        {
            if ($Force -or !(Test-GocsPackage -Id $PackageId -Version $Match.Value -Server $Server -Port $Port))
            {
                [System.IO.Directory]::CreateDirectory($OutputDir) | Out-Null
                $OutputFilePath = Join-Path $OutputDir 'TortoiseGit.msi'
                Invoke-WebRequest -Uri $Url -OutFile $OutputFilePath
                $Description = 'TortoiseGit provides overlay icons showing the file status, a powerful context menu for Git and much more!'
                $Package = New-MsiPackage -PackageId $PackageId -PackageName "Tortoise Git" -Description $Description -SetupPath $OutputFilePath -OutputDir $OutputDir -Force:$Force

                if ($Import)
                {
                    $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
                }
                $Package
            }
        }
    }
}