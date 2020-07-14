param(
    [Parameter(Mandatory = $true)]
    $OutputDir,
    $Server,
    $Port,
    [switch] $Import,
    [switch] $Force
)
Import-Module (Join-Path $PSScriptRoot 'VS Code\NewPackage.ps1') -Force
Import-Module (Join-Path $PSScriptRoot 'Git\NewPackage.ps1') -Force
Import-Module (Join-Path $PSScriptRoot 'TortoiseGit\NewPackage.ps1') -Force
Import-Module (Join-Path $PSScriptRoot 'SqlManagementStudio\NewPackage.ps1') -Force
Import-Module (Join-Path $PSScriptRoot 'ServiceTierAdministrator\NewPackage.ps1') -Force
Import-Module (Join-Path $PSScriptRoot 'Chrome\NewPackage.ps1') -Force

[System.IO.Directory]::CreateDirectory($OutputDir) | Out-Null

New-VsCodePackageFromWeb -OutputDir $OutputDir -Import:$Import -Server $Server -Port $Port -Force:$Force

New-GitPackageFromWeb -Server $Server -Port $Port -OutputDir $OutputDir -Import:$Import -Force:$Force

New-TortoiseGitPackageFromWeb -Server $Server -Port $Port -OutputDir $OutputDir -Import:$Import -Force:$Force

New-SqlStudioPackageFromWeb -OutputDir $OutputDir -Import:$Import -Server $Server -Port $Port -Force:$Force

New-ServiceTierAdministratorPackageFromWeb -OutputDir $OutputDir -Import:$Import -Server $Server -Port $Port -Force:$Force

New-ChromePackageFromWeb -OutputDir $OutputDir -Import:$Import -Server $Server -Port $Port -Force:$Force