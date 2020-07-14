$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $User = "$($env:UserDomain)\$($env:USERNAME)"
    $Arguments = "/q /Hideconsole /ACTION=Install /SQLSYSADMINACCOUNTS=`"$User`" /ASSYSADMINACCOUNTS=`"$User`" /ROLE=AllFeatures_WithDefaults /INSTANCENAME=$($Context.Arguments.InstanceName) /IACCEPTSQLSERVERLICENSETERMS=TRUE"
    if (![string]::IsNullOrEmpty($Context.Arguments.Arguments))
    {
        $Arguments = $Context.Arguments.Arguments
    }

    $ValidExitCodes = @(0, 3010)

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
    
    $SetupPath = (Join-Path $Context.TemporaryDirectory "setup.exe")
    $Output = Invoke-Expression "& `"$SetupPath`" $Arguments | Out-String"
    if ($LASTEXITCODE -notin $ValidExitCodes)
    {
        Write-Host $Output
        throw "SQL express install failed with exit code: $LASTEXITCODE"
    }
}