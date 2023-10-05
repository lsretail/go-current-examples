$ErrorActionPreference = 'stop'

Import-Module LsPackageTools\AppPackageCreator -Force

$BaseAppPath = Join-Path $PSScriptRoot 'Cronus_Cronus.Base_1.0.0.0.app'
$ApiAppPath = Join-Path $PSScriptRoot 'Cronus_Cronus.Api_1.0.0.0.app'
$OutputDir = Join-Path $PSScriptRoot 'Output-Multi'

### EXAMPLE 1 #######################################
# Default values.

@($BaseAppPath, $ApiAppPath) | New-AppPackageFromContext -OutputDir $OutputDir -Force

# This example creates packages for the apps piped into the function, it generates
# a package ID and name from the values in app.json and adds dependencies to
# known packages, listed in the app.json file.
#
# Note that the Cronus.Api app depends on the Cronus.Base app, and as both apps
# are supplied to the function it will know how to setup the dependencies 
# between the packages.
# If you only supply the Cronus.Api app, you would get an error:
# PS> $ApiAppPath | New-AppPackageFromContext -OutputDir $OutputDir -Force
# PS> Could not find package ID equivalent for app ID "c61cfd91-3499-4912-989e-2f84664b3ced"


### EXAMPLE 2 #######################################
# Generate custom ID and name.

$Arguments = @{
    Id = { "example-2-$($_.Name)" }
    Name = "Example 2 $($_.Name)"
    OutputDir = $OutputDir
}

@($BaseAppPath, $ApiAppPath) | New-AppPackageFromContext @Arguments -Force

# This example does the same as example 1, except the ID and name are generated 
# from the app.json values.


### EXAMPLE 3 #######################################
# Fixed ID and name.

$Apps = @(
    [PSCustomObject]@{
        Id = 'example-3-base-app'
        Name = 'Example 3 Base App'
        Path = $BaseAppPath
    }
    [PSCustomObject]@{
        Id = 'example-3-api-app'
        Name = 'Example 3 Api App'
        Path = $ApiAppPath
    }
)

$Apps | New-AppPackageFromContext -OutputDir $OutputDir -Force

# This example does the same as example 1, except the names and ID's of the 
# packages are fixed.


### EXAMPLE 4 #######################################
# Predefined map.

$Map = @{
    "c61cfd91-3499-4912-989e-2f84664b3ced" = @{
        Id = "example-4-base-app"
        Name = "Example 4 Base App"
    }
    "6ed20322-04fc-4668-91a4-1388e8470eb0" = @{
        Id = 'example-4-api-app'
        Name = "Example 4 Api App"
    }
}

$Arguments = @{
    OutputDir = $OutputDir
    AppToPackageMap = $Map
}

@($BaseAppPath, $ApiAppPath) | New-AppPackageFromContext @Arguments -Force

# This example does the same as example 1, except this uses a predefined map to
# determine the ID and name of each package.
# -AppToPackageMap also accepts a path to a JSON file in the same format.


### EXAMPLE 5 #######################################
# App not available.

$Map = @{
    "c61cfd91-3499-4912-989e-2f84664b3ced" = @{
        Id = "example-5-base-app"
        Name = "Example 5 Base App"
        Parts = 3
        Type = "FromMinorToNextMajor"
    }
    "6ed20322-04fc-4668-91a4-1388e8470eb0" = @{
        Id = 'example-5-api-app'
        Name = "Example 5 Api App"
        Parts = 3
    }
}

$Arguments = @{
    OutputDir = $OutputDir
    AppToPackageMap = $Map
}

$ApiAppPath | New-AppPackageFromContext @Arguments -Force

# This example does the same as example 4, except it only supplies a path for
# Cronus.Api app (only creates a package for Cronus.Api).
# But a map, -AppToPackageMap is specified, which allows the function to create
# a dependency between them.
# This is useful if an app is not available in a particular process.

### EXAMPLE 6 #######################################
# Include AppMetadata and ExtraDependencies in map.
# Available in ls-package-tools v0.9.0 and later.

$Map = @{
    "c61cfd91-3499-4912-989e-2f84664b3ced" = @{
        Id = "example-6-base-app"
        Name = "Example 6 Base App"
        Parts = 3
        ExtraDependencies = @(
            # If the app uses a DOTNET add-in, you can specify the it's package ID and minimum version.
            @{ Id = 'example-addin'; VersionQuery = '>=1.0.0'}
        )
    }
    "6ed20322-04fc-4668-91a4-1388e8470eb0" = @{
        Id = 'example-6-api-app'
        Name = "Example 6 Api App"
        Parts = 3
        AppMetadata = @{
            # To allow Update Service to force breaking schema changes, you can specify a
            # version of the app that introduces the breaking changes.
            ForceVersion = '1.0.0'
        }
    }
}

$Arguments = @{
    OutputDir = $OutputDir
    AppToPackageMap = $Map
}

$ApiAppPath | New-AppPackageFromContext @Arguments -Force

# This example does the same as example 4, except it only supplies a path for
# Cronus.Api app (only creates a package for Cronus.Api).
# But a map, -AppToPackageMap is specified, which allows the function to create
# a dependency between them.
# This is useful if an app is not available in a particular process.