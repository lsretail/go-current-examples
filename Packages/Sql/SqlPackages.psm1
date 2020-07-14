$ErrorActionPreference = 'Stop'

Import-Module GoCurrentServer

function New-SqlServerExpressPackage
{
    param(
        [Parameter(Mandatory = $true)]
        $SetupPath,
        [Parameter(Mandatory = $true)]
        $OutputDir, 
        [Parameter(Mandatory = $false)]
        $Server, 
        [Parameter(Mandatory = $false)]
        $Port, 
        [Switch] $Force
    )
    $FileName = Split-Path $SetupPath -Leaf

    if ($FileName -ine 'SQLEXPR_x64_ENU.EXE')
    {
        throw "Setup file name must be SQLEXPR_x64_ENU.EXE."
    }

    $SqlExpressPackage = @{
        Id = 'sql-server-express'
        Name = 'Microsoft SQL Server Express'
        Version = $SetupPath
        InputPath = @(
            $SetupPath,
            (Join-Path (Join-Path $PSScriptRoot 'sql-server-express') '*')
        )
        OutputDir = $OutputDir
        Commands = @{
            Install = 'Package.psm1:Install-Package'
        }
        Parameters = @(
            @{ Description = 'Arguments for installer'; Key = 'Arguments'; Hidden = $true }
            @{ Description = 'SQL Server Instance Name'; Key = 'InstanceName'; Default = 'SQLEXPRESS' }
        )
        WindowsUpdateSensitive = $true
        FillParameters = @{
            'system' = @{
                'SqlServerInstanceName' = '${InstanceName}'
                'SqlServerName' = 'localhost'
            }
        }
    }
    New-GocsPackage @SqlExpressPackage -Force:$Force | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
}

function New-SqlManagementStudioPackage
{
    param(
        [Parameter(Mandatory = $true)]
        $SetupPath,
        [Parameter(Mandatory = $true)]
        $OutputDir,
        [Parameter(Mandatory = $false)]
        $Server,
        [Parameter(Mandatory = $false)]
        $Port,
        [Switch] $Force,
        [Switch] $Import
    )
    $FileName = Split-Path $SetupPath -Leaf

    if ($FileName -ine 'SSMS-Setup-ENU.exe')
    {
        throw "Setup file name must be SSMS-Setup-ENU.exe."
    }

    $Management = @{
        Id = 'sql-management-studio'
        Name = 'SQL Management Studio'
        Version = $SetupPath
        InputPath = @(
            $SetupPath,
            (Join-Path (Join-Path $PSScriptRoot 'sql-management-studio') '*')
        )
        OutputDir = $OutputDir
        Commands = @{
            Install = 'Package.psm1:Install-Package'
        }
        Instance = $false
    }

    $Package = New-GocsPackage @Management -Force:$Force 
    if ($Import)
    {
        $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
    }
    $Package
}

function New-SqlServerPackage
{
    param(
        [Parameter(Mandatory = $true)]
        $SetupDir,
        [Parameter(Mandatory = $true)]
        $OutputDir,
        [Parameter(Mandatory = $false)]
        $Server,
        [Parameter(Mandatory = $false)]
        $Port,
        [Switch] $Force
    )

    if (!(Test-Path (Join-Path $SetupDir 'setup.exe')))
    {
        throw "Setup.exe does not exists in setup directory ($SetupDir)."
    }

    $SqlPackage = @{
        Id = 'sql-server'
        Name = 'Microsoft SQL Server'
        Version = (Join-Path $SetupDir 'setup.exe')
        InputPath = @(
            (Join-Path $SetupDir '*'),
            (Join-Path (Join-Path $PSScriptRoot 'sql-server') '*')
        )
        OutputDir = $OutputDir
        Commands = @{
            Install = 'Package.psm1:Install-Package'
        }
        Parameters = @(
            @{ Description = 'Arguments for installer'; Key = 'Arguments'; Hidden = $true }
            @{ Description = 'SQL Server Instance Name'; Key = 'InstanceName'; Default = 'MSSQLSERVER' }
        )
        WindowsUpdateSensitive = $true
        FillParameters = @{
            'system' = @{
                'SqlServerInstanceName' = '${InstanceName}'
                'SqlServerName' = 'localhost'
            }
        }
    }
    New-GocsPackage @SqlPackage -Force:$Force | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
}