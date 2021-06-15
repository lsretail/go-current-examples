$ErrorActionPreference = 'stop'

& (Join-Path $PSScriptRoot 'Build.ps1') -Target 'Dev' -Commit '5b880caea314fae59fbe4a9ca62d75f0bf7f632a' -BuildNumber 21 -BranchName 'master' -Force