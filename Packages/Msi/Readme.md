# Msi example package

The `New-MsiPackage` cmdlet is a generic function to create a package from a MSI setup file. You must provide a package id and name, while the version number is obtained from the provided setup file and set as the package version number.

```powershell
Import-Module (Join-Path $PSScriptRoot 'MsiPackage.psm1')

New-MsiPackage -PackageId 'msi-package' -PackageName 'Msi Package' -SetupPath 'c:\path\to\msi\setup.msi' -OutputDir 'c:\path\to\package\output\dir' -Force
```

This example shows the generic use of the cmdlet, this will create a new package called *msi-package* and is imported into a Go Current server installed on the same machine. To import to a server on a different machine use the *-Server* and *-Port* parameters.

```powershell
Import-Module (Join-Path $PSScriptRoot 'MsiPackage.psm1')

New-MsiPackage -PackageId 'ms-sql-report-builder' -PackageName 'Microsoft SQL Server Report Builder' -SetupPath 'c:\path\to\msi\ReportBuilder3.msi' -OutputDir 'c:\path\to\package\output\dir' -Force
```

This example will create a package for the Microsoft SQL Server Report Builder from a provided setup file.