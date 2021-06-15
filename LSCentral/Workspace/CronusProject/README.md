# Cronus Project

Here is an example AL project with [LS Update Service Workspace](https://marketplace.visualstudio.com/items?itemName=lsretail.ls-update-service-workspace) set up.

## Install Development Environment

From within VS Code you can install LS Central with different configurations, press *F1->LS Update Service: Install Packages* and you get a selection of the following options:

* **LS Central - from app.json**: Install LS Central of the same version as defined in *app.json* (18.0), with demo data.
* **LS Central - from app.json, existing DB**: Same as above, except the service tier, connects to an existing database. The following are requirements for the database:
    * Is running LS Central/Business Central 15.0 or above.
    * Database's platform version is the same or earlier version than the POS bundle will install.
    * All apps in the existing database are the same or earlier versions than the POS bundle will install.
    * Other requirements may apply.
* **LS Central - fixed version**: Install a version of LS Central, defined with *LsCentralFixedVersion* variable.
* **LS Central - latest**: Install the latest version of LS Central.

## Continuous Integration (Build)

The project can be built using a [build script](.\Build\Build.ps1), to produce both the app files and the packages and without involving a service tier in the process. It does so, by downloading the dependency apps from the Go Current server and uses them as symbols files.

The build script supports targets, *Dev*, *ReleaseCandidate*, and *Release*, which affect the versioning of the packages produced.
*Dev* and *ReleaseCandidate* produces packages with pre-release versions, for example:
* **Dev**: 1.0.0-dev.0.master.11+5b880cae
* **ReleaseCandidate**: 1.0.0-rc.54+5b880cae
* **Release**: 1.0.0+5b880cae

See *Test Environment* section below for further details on how to install these different targets.

Here is an example how to run the build script:
```powershell
PS> .\Build\Build.ps1 -Target 'Dev' -Commit '5b880caea314fae59fbe4a9ca62d75f0bf7f632a' -BuildNumber 21 -BranchName 'master' -Force
```
This example builds with target *Dev* and manually specifies information from Git and a build number.
If you hook this into your build server, such as *Azure Devops*, or *Atlassian Bamboo*, and have them provide this context.

When the build script has executed successfully, you can run a deployment script to import the packages into your Go Current server: 
```powershell
PS> .\Build\Depoy.ps1 -Target 'Dev' [-Server 'my-server.mydomain.local'] [-Port 16650]
```

The packages are created in *.\Packages\TARGET*

### Requirements

The following components must be installed on the build machine:

* Go Current client, configured to talk to your server.
* Go Current server cmdlets (the server does not need to be operational, nor have a database).
    * Package ID: *go-current-client*
* LS Package Tools
    * Package ID: *ls-package-tools*
* Your GoC server must have the *bc-al-compiler* package.
    ```powershell
    Import-Module GoCurrentServer
    Copy-GocsPackagesFromServer -Id 'bc-al-compiler' -SourceServer 'gocurrent.lsretail.com' -SourceUseSsl -SourceIdentity 'lsretail.com'
    ```

You can install these requirements with [Requirements.ps1](.\Build\Requirements.ps1):
```powershell
PS> .\Build\Requirements.ps1 -Server 'my-server.mydomain.local'
```
Where *-Server* points to your Go Current server.

## Test Environment

### Install Branch

If you have set up the build script to run for every push to a Git branch on a remote repository and continuously deploy the packages to your Go Current server, then you can install a snapshot of each branch:

```PowerShell
PS> .\Scripts\InstallDevBranch.ps1 -BranchName 'my-branch'
```

Note: You have to have the Go Current client installed in the machine and configured to talk to your server.

This example will install a snapshot of the *my-branch* branch if it exists, otherwise, it will fall back to the master branch.

### Install Release Candidate

To install the latest release candidate:

```powershell
PS> .\Scripts\InstallReleaseCandidate.ps1
```

### Install Release

To install the latest release:

```powershell
PS> .\Scripts\InstallReleaseCandidate.ps1
```