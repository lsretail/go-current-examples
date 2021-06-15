$ErrorActionPreference = 'stop'

Import-Module LsPackageTools\AppPackageCreator

$AppPath = (Join-Path $PSScriptRoot 'Cronus_Cronus.Base_1.0.0.0.app')
$OutputDir = Join-Path $PSScriptRoot 'Output-Single'

### EXAMPLE 1 #######################################
# Default values.

$Arguments = @{
    Path = $AppPath
    OutputDir = $OutputDir
}

New-AppPackageFromContext @Arguments -Force

# This example creates a package for specified app, it generates
# a package ID and name from the app.json values and adds dependencies to
# known packages, that are listed in app.json.
# The package is created in the Output directory.


### EXAMPLE 2 #######################################
# Fixed ID and name.

$Arguments = @{
    Path = $AppPath
    Id = 'example-2-app'
    Name = 'Example 2 app'
    OutputDir = $OutputDir
}

New-AppPackageFromContext @Arguments -Force

# This example does the same as example 1, except it gives the packages a 
# fixed ID and name is specified.


### EXAMPLE 3 #######################################
# Generated custom ID and name.

$Arguments = @{
    Path = $AppPath
    Id = { "example-3-$($_.Name)-app"}
    Name = { "Example 3 $($_.Name)"}
    OutputDir = $OutputDir
}

New-AppPackageFromContext @Arguments -Force

# This example does the same as example 1, except the ID and name are generated 
# from the app.json values.


### EXAMPLE 4 #######################################
# Additonal dependency not listed in app.json.

$Arguments = @{
    Path = $AppPath 
    Id = 'example-4' 
    OutputDir = $OutputDir 
    ExtraDependencies = @(
        @{ Id = 'my-addin'; Version = '>=1.0.0'}
    ) 
}

New-AppPackageFromContext @Arguments -Force

# This example creates a package for specified app and the dependencies listed in app.json,
# with an extra dependency, a addin package (DLL/assemblies) that is required by the app.