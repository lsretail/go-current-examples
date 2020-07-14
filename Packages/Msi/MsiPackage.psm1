$ErrorActionPreference = 'Stop'

Import-Module GoCurrentServer
Import-Module (Join-Path $PSScriptRoot 'msi\Package.psm1')

function New-MsiPackage
{
    param(
        [Parameter(Mandatory = $true)]
        $PackageId,
        [Parameter(Mandatory = $true)]
        $PackageName,
        [Parameter(Mandatory = $false)]
        $PackageDisplayName = $null,
        $Description,
        [Parameter(Mandatory = $true)]
        $SetupPath,
        [Parameter(Mandatory = $true)]
        $OutputDir, 
        [Switch] $Force
    )

    $MsiPath = Get-MsiExePath -Path $SetupPath
    $MsiInfo = Get-MsiInfo -Path $MsiPath
    $InputPath = $MsiPath
    if ($MsiPath -ine $SetupPath)
    {
        $InputPath = (Join-Path $SetupPath '*')
    }

    $Package = @{
        Id = $PackageId
        Name = $PackageName
        DisplayName = $PackageDisplayName
        Description = $Description
        Version = $MsiInfo.ProductVersion
        InputPath = @(
            $InputPath,
            (Join-Path (Join-Path $PSScriptRoot 'msi') '*')
        )
        OutputDir = $OutputDir
        Commands = @{
            'Install' = 'Package.psm1:Install-Package'
            'Update' = 'Package.psm1:Install-Package'
            'Remove' = 'Package.psm1:Remove-Package'
        }
        Parameters = @(
            @{ Description = "Product Code"; Key = "ProductCode"; DefaultValue = $MsiInfo.ProductCode; Hidden = $true}
        )
    }
    New-GocsPackage @Package -Force:$Force
}

function Get-MsiInfo()
{
    param (
        [IO.FileInfo] $Path
    )

    function GetMsiValue($Database, $Property)
    {
        $Query = "SELECT Value FROM Property WHERE Property = '$Property'"
        $View = $Database.GetType().InvokeMember(
                "OpenView", "InvokeMethod", $Null, $Database, ($Query)
            )

        $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null) | Out-Null

        $Record = $View.GetType().InvokeMember(
                "Fetch", "InvokeMethod", $Null, $View, $Null
            )

        $Value = $Record.GetType().InvokeMember(
                "StringData", "GetProperty", $Null, $Record, 1
            )

        $View.GetType().InvokeMember("Close", "InvokeMethod", $Null, $View, $Null) | Out-Null
        return $Value
    }

    try 
    {
        $WindowsInstaller = New-Object -com WindowsInstaller.Installer

        $Database = $WindowsInstaller.GetType().InvokeMember(
                "OpenDatabase", "InvokeMethod", $Null, 
                $WindowsInstaller, @($Path.FullName, 0)
            )

        $ProductVersion = GetMsiValue -Database $Database -Property 'ProductVersion'
        $ProductCode = GetMsiValue -Database $Database -Property 'ProductCode'
        
        return @{
            ProductVersion = $ProductVersion
            ProductCode = $ProductCode
        }
    } 
    catch 
    {
        throw "Failed to get MSI file version the error was: {0}." -f $_.Exception
    }
}