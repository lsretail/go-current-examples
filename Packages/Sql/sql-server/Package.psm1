$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $InstanceName = 'MSSQLSERVER'
    if ($Context.Arguments.InstanceName)
    {
        $InstanceName = $Context.Arguments.InstanceName
    }

    $Users = "`"$($env:UserDomain)\$($env:USERNAME)`""
    if ($Context.Arguments.AdminUser)
    {
        $Users = $Context.Arguments.AdminUser.Split(',') | ForEach-Object { "`"$($_.Trim())`"" }
    }

    $ArgumentList = @(
        '/q', '/Hideconsole', '/ACTION=Install', "/SQLSYSADMINACCOUNTS=$Users", "/ASSYSADMINACCOUNTS=$Users",
        "/INSTANCENAME=$($InstanceName)", "/IACCEPTSQLSERVERLICENSETERMS=TRUE"
    )

    if ($Context.Arguments.Features -eq 'All')
    {
        $Features = "/ROLE=AllFeatures_WithDefaults"
    }
    else
    {
        $Features = "/FEATURES=SQLEngine"
    }
    $ArgumentList += $Features

    $Arguments = [string]::Join(' ', $ArgumentList)
    if (![string]::IsNullOrEmpty($Context.Arguments.Arguments))
    {
        $Arguments = $Context.Arguments.Arguments
        # Make sure we pass silent parameters to the installer.
        $ArgumentList = $Arguments.ToLower().Split(" ")
        if (!$ArgumentList.Contains("/q"))
        {
            $Arguments = "$Arguments /q"
        }
        if (!$ArgumentList.Contains("/hideconsole"))
        {
            $Arguments = "$Arguments /Hideconsole"
        }
    }

    $ValidExitCodes = @(0, 3010)
    
    $SetupPath = Join-Path $Context.TemporaryDirectory "*.exe" -Resolve
    $Output = Invoke-Expression "& `"$SetupPath`" $Arguments | Out-String"
    if ($LASTEXITCODE -notin $ValidExitCodes)
    {
        Write-Host $Output
        throw "SQL express install failed with exit code: $LASTEXITCODE"
    }
}