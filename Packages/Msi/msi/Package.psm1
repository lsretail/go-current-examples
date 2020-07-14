$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $MsiExePath = Get-MsiExePath -Path $Context.TemporaryDirectory
    Install-Msi -Path $MsiExePath
}

function Remove-Package($Context)
{
    if (!$Context.Arguments.ProductCode)
    {
        throw "No product code provided."
    }

    Remove-Msi -ProductCode $Context.Arguments.ProductCode
}

function Install-Msi
{
    param(
        [Parameter(Mandatory = $true)]
        $Path,
        [Parameter(Mandatory = $false)]
        $ValidExitCodes = @(0),
        [Parameter(Mandatory = $false)]
        [Array] $ArgumentList = @()
    )

    foreach ($InstallerPath in (Resolve-Path $Path))
    {
        $InstallerItem = Get-Item $InstallerPath

        $Arguments = @("/i", "`"$InstallerPath`"")
        $Arguments += $ArgumentList
        Invoke-Msi -LogName $InstallerItem.BaseName -ValidExitCodes $ValidExitCodes -ArgumentList $Arguments
    }
}

function Remove-Msi
{
    param(
        [Parameter(Mandatory = $true)]
        $ProductCode,
        [Parameter(Mandatory = $false)]
        $ValidExitCodes = @(0),
        [Parameter(Mandatory = $false)]
        [Array] $ArgumentList = @()
    )

    $Arguments = @("/x", $ProductCode)
    $Arguments += $ArgumentList

    Invoke-Msi -LogName 'GoCRemove' -ValidExitCodes $ValidExitCodes -ArgumentList $Arguments
}

function Invoke-Msi
{
    param(
        $LogName,
        $ValidExitCodes = @(0),
        [Array] $ArgumentList = @()
    )
    
    $LogFile = Join-Path $env:TEMP "MSILOG_$LogName.log"

    $Arguments = @("/quiet", "/le", "$LogFile", "/norestart")
    $Arguments += $ArgumentList

    $Process = Start-Process "msiexec" -ArgumentList $Arguments -PassThru
    $Process.WaitForExit();
    if ($Process.ExitCode -notin $ValidExitCodes)
    {
        if (Test-Path $LogFile)
        {
            $Log = Get-Content -Raw $LogFile
            if ($Log)
            {
                Write-Verbose "Msiexec log: $Log"
            }
        }
        throw "Running msiexec failed with exit code $($Process.ExitCode)"
    }
    
    Remove-Item $LogFile -ErrorAction SilentlyContinue
}

function Get-MsiExePath
{
    param($Path)

    $MsiExePath = $Path
    if ((Get-Item $Path) -is [System.IO.DirectoryInfo])
    {
        $Items = @(Get-ChildItem $Path -Filter '*.msi')
        if ($Items.Length -gt 1)
        {
            throw "Found two or more ($($Items.Length)) *.msi files in '$Path'."
        }
        elseif ($Items.Length -eq 0)
        {
            throw "No *.msi files found in '$Path'."
        }
        $MsiExePath = ($Items | Select-Object -First 1).FullName
    }
    return $MsiExePath
}