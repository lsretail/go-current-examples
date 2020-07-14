# SQL example packages

## SQL Server Example

```powershell
Import-Module (Join-Path $PSScriptRoot 'SqlPackages.psm1')

New-SqlManagementStudioPackage -SetupDir 'c:\path\to\sql\setup\dir' -OutputDir 'c:\path\to\package\output\dir' -Force
```

This example will create a new SQL Server package from a provided SQL Server setup directory and imported into Go Current server installed on the same machine. If the package already exists, it's overwritten.

## SQL Server Express Example

```powershell
Import-Module (Join-Path $PSScriptRoot 'SqlPackages.psm1')

New-SqlServerExpressPackage -SetupPath 'c:\path\to\SQLEXPR_x64_ENU.EXE' -OutputDir 'c:\path\to\package\output\dir' -Force
```

This example will create a new SQL Server Express package from provided setup file (*SQLEXPR_x64_ENU.EXE*) and imported to a Go Current server installed on the same machine. If package already exists, it will be overwritten.
A setup file can be downloaded from [here](https://www.microsoft.com/en-us/sql-server/sql-server-editions-express), you must first download an online installer and from there choose *Download Media* where you will get a file called *SQLEXPR_x64_ENU.EXE*.

## SQL Management Studio Example

```powershell
Import-Module (Join-Path $PSScriptRoot 'SqlPackages.psm1')

New-SqlManagementStudioPackage -SetupPath 'c:\path\to\SSMS-Setup-ENU.exe' -OutputDir 'c:\path\to\package\output\dir' -Force -Server 'localhost' -Port 16652
```

This example will create a new SQL Management Studio package from a provided setup file and import it to a Go Current server installed on the same machine. 
A setup file can be downloaded from [here](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms).
