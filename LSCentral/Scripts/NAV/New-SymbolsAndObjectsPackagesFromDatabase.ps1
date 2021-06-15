<#
    .SYNOPSIS
        Create new symbols and objects packages from database.

    .DESCRIPTION
        This script will install a new service-tier/NST and connect to specified database.
        Then it will perform the following:
            1. Generate symbols for all objects in the database.
            2. Download a symbols app.
            3. Create an app package from the symbols app.
            4. Export all objects to a FOB file.
            5. Create an objects package from the FOB file.
            6. If specified, the packages are imported into a Go Current server.

        You might want to adjust the package names in the script as well the dependencies to your requirements.

        When you update the objects functionality and want to release them, 
        you must create new objects and app packages by running this script 
        with a new version number higher than the previous.

    .EXAMPLE
        $Arguments = @{
            Version = '1.0.0'
            SqlInstance = 'localhost\SQLExpress'
            DatabaseName = 'MyDatabase'
            BcVersion = '14.0.35916.0'
            InstanceName = 'MyInstance'
            OutputDir = 'c:\Temp\OutputDir'
            Import = $true
            Force = $true
        }

        .\New-SymbolsAndObjectsPackagesFromDatabase.ps1 @Arguments

        This example will install a new service-tier/NST instance (v14.0.35916.0) called "MyInstance", connected to the database "MyDatabase".
        It will generate and export symbols and objects into the output directory and create two packages, my-application-symbols and my-objects of version 1.0.0.
        All output files will be put into c:\Temp\OutputDir and all existing files will be overwritten.
        The packages are imported to a Go Current server on localhost.

    .NOTES
        The database must already have a valid license.
#>

param(
    [Parameter(Mandatory)]
    $Version,
    $SqlInstance = 'localhost',
    [Parameter(Mandatory)]
    $DatabaseName,
    [Parameter(Mandatory)]
    $BcVersion,
    [Parameter(Mandatory)]
    $InstanceName,
    [Parameter(Mandatory)]
    $OutputDir,
    $Server,
    $Port,
    [switch] $Import,
    [switch] $Force
)

$ErrorActionPreference = 'stop'

Import-Module GoCurrent
Import-Module LsPackageTools\ObjectPackageCreator
Import-Module LsPackageTools\AppPackageCreator


$Arguments = @{
    'bc-server' = @{
        ConnectionString = "Data Source=$SqlInstance;Initial Catalog=$DatabaseName;Integrated Security=True"
        NoDatabaseUpgrades = 'true'
        DeveloperServicesEnabled = 'true'
        EnableSymbolLoadingAtServerStartup = 'true'
    }
}

$Packages = @(
    @{ Id = 'bc-server'; Version = $BcVersion}
)

$Packages | Install-GocPackage -InstanceName $InstanceName -Arguments $Arguments -UpdateInstance

$SymbolsPath = Join-Path $OutputDir 'Symbols.app'
$ObjectsPath = Join-Path $OutputDir 'Objects.fob'

$Arguments = @{
    InstanceName = $InstanceName 
    OutputPath = $SymbolsPath 
    GenerateSymbols = $true
}

Export-ApplicationSymbols @Arguments -Verbose

$Arguments = @{
    OutputFobPath = $ObjectsPath
    InstanceName = $InstanceName
}

Export-ObjectsForPackage @Arguments -Force:$Force

$Package = @{
    Id = "my-objects"
    Name = "My Objects"
    Version = $Version
    FobPath = $ObjectsPath
    ForceDestructiveChanges = $true
    Dependencies = @(
        @{ Id = 'bc-server'; Version = "=$BcVersion"}
    )
    SkipValidation = $true
    OutputDir = $OutputDir
}

$Packages = @(New-ObjectPackage @Package -Force:$Force)

# Create symbols package from path:
$Package = @{
    Id = 'my-application-symbols'
    Name = 'My Symbols'
    Version = $Version
    Path = $SymbolsPath
    OutputDir = $OutputDir
    SymbolsOnly = $true
    Dependencies = @(
        @{ Id = $Package.Id; Version = $Version }
    )
}

$Packages += New-AppPackage @Package -Force:$Force | Import-GocsPackage -Force:$Force

if ($Import)
{
    $Packages | Import-GocsPackage -Server $Server -Port $Port -Force:$Force
}