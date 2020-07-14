$ErrorActionPreference = 'stop'

function Install-Package($Context)
{
    $Arguments = "/q /Hideconsole /ACTION=Install /ROLE=AllFeatures_WithDefaults /INSTANCENAME=$($Context.Arguments.InstanceName) /ADDCURRENTUSERASSQLADMIN=TRUE /IACCEPTSQLSERVERLICENSETERMS=TRUE"
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
    
    $SetupPath = (Join-Path $Context.TemporaryDirectory "SQLEXPR_x64_ENU.EXE")
    $Output = Invoke-Expression "& `"$SetupPath`" $Arguments | Out-String"
    if ($LASTEXITCODE -notin $ValidExitCodes)
    {
        Write-Host $Output
        throw "SQL express install failed with exit code: $LASTEXITCODE"
    }
}