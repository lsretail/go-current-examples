$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    Write-Progress -Id 217 -Activity 'Installing SQL Server' -Status "Installing..."
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

    if ($Context.Arguments.UseSecurityModeSql -and ([Convert]::ToBoolean($Context.Arguments.UseSecurityModeSql)))
    {
        $Password = Get-Password $Context.Arguments.SaPassword
        if (!$Password)
        {
            Write-PackageError -Message "SA password is required for SQL authentication."
            throw "SA password is required for SQL authentication."
        }

        $ArgumentList += '/SECURITYMODE=SQL'
        $ArgumentList += "/SAPWD=$Password"
    }

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
    
    $SetupPath = Join-Path $Context.TemporaryDirectory "*.exe" -Resolve | Select-Object -First 1
    $Output = Invoke-Expression "& `"$SetupPath`" $Arguments | Out-String"
    if ($LASTEXITCODE -notin $ValidExitCodes)
    {
        Write-Host $Output
        throw "SQL express install failed with exit code: $LASTEXITCODE"
    }
}

function Update-Package($Context)
{
    Write-Progress -Id 217 -Activity 'Updating SQL Server' -Status "Updating..."
    $InstanceName = 'MSSQLSERVER'
    if ($Context.Arguments.InstanceName)
    {
        $InstanceName = $Context.Arguments.InstanceName
    }

    $ArgumentList = @(
        '/q', '/Hideconsole', '/ACTION=Upgrade',
        "/INSTANCENAME=$($InstanceName)", "/IACCEPTSQLSERVERLICENSETERMS=TRUE"
    )

    $ValidExitCodes = @(0, 3010)
    
    $SetupPath = Join-Path $Context.TemporaryDirectory "*.exe" -Resolve | Select-Object -First 1
    $Output = & $SetupPath @ArgumentList | Out-String
    if ($LASTEXITCODE -notin $ValidExitCodes)
    {
        Write-Host $Output
        throw "SQL express install failed with exit code: $LASTEXITCODE"
    }
}


function Get-Password
{
    param(
        $Value
    )

    try
    {
        if ([string]::IsNullOrEmpty($Value))
        {
            $Password = ""
        }
        else
        {
            try
            {
                $Password = $Value | ConvertTo-SecureString
                Write-Host "Using secure text password."
            }
            catch
            {
                Write-Host "Assuming plain text password."
                $Password = ConvertTo-SecureString $Value -AsPlainText -Force
            }
        }
    }
    catch
    {
        Write-Warning "Error occurred while decrypting password: $_"
        $Password = $Value
    }
    return $Password
}