<#
    .SYNOPSIS
        Create a new SQL server package.
    
    .PARAMETER SetupDir
        Specifies a directory containing the SQL server setup.
    
    .PARAMETER OutputDir
        Specifies a directory where the package is created.
    
    .PARAMETER Edition
        Specifies which SQL server edition. This affects the 
        name and ID of the package.
    
    .PARAMETER Force
        Specify to overwrite existing package file.
#>
param(
    [Parameter(Mandatory)]
    $SetupDir,
    [Parameter(Mandatory)]
    $OutputDir,
    [ValidateSet('Regular', 'Express', 'Developer')]
    $Edition = 'Regular',
    $Server,
    $Port,
    [Switch] $Force,
    [Switch] $Import
)

$ErrorActionPreference = 'stop'

$SetupPath = Join-Path $SetupDir '*.exe' -Resolve

if (!$SetupPath)
{
    throw "No executable found in the setup directory ($SetupDir)."
}

$NamePostfix = ''
$EditionPostfix = ''
$InstanceName = ''
$SetupFileName = 'setup.exe'
if ($Edition -eq 'Express')
{
    $NamePostfix = ' Express'
    $EditionPostfix = '-express'
    $SetupFileName = 'SQLEXPR_x64_ENU.EXE'
    $InstanceName = 'SQLEXPRESS'
}
elseif ($Edition -eq 'Developer')
{
    $NamePostfix = ' Developer'
    $EditionPostfix = '-developer'
}

$SqlPackage = @{
    Id = "sql-server$EditionPostfix"
    Name = "Microsoft SQL Server$NamePostfix"
    Description = "A relational database management system."
    Version = (Join-Path $SetupDir $SetupFileName)
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
        @{ Description = 'SQL Server Instance Name'; Key = 'InstanceName'; Default = $InstanceName; Hint ="Leave empty for default instance `"MSSQLSERVER`"." }
        @{ Description = 'Features'; Key = "Features"; Default = "SqlOnly"; Widget = 'Dropdown'; Labels = @('All Features', 'SQL Server Only'); Values = @('All', 'SqlOnly') }
        @{ Description = 'Admin User'; Key = 'AdminUser'; Default = ''; Hint = "On the form DOMAIN\USER. Leave empty for current user."}
    )
    WindowsUpdateSensitive = $true
    FillParameters = @{
        'system' = @{
            'SqlServerInstanceName' = '${InstanceName}'
            'SqlServerName' = 'localhost'
        }
    }
}

$Package = New-GocsPackage @SqlPackage -Force:$Force
if ($Import)
{
    $Package | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
}
$Package