#to reset KMS Key-Setting, you can use that script


#Detection
[CmdletBinding()]
Param ()
# Ensure we actually properly stop on any errors.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
Set-PSDebug -Strict
Set-StrictMode -Version Latest
# Confirm whether device is activated already.
if (!(Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "Name like 'Windows%' and PartialProductKey like '%' and LicenseStatus = 1"))
{
    Write-Output "Microsoft Windows is not activated"
    Exit 1
}
else
{
    Write-Output "Microsoft Windows is activated, all good"
    Exit 0
    }

#Remediation
[CmdletBinding()]
Param ()
# Ensure we actually properly stop on any errors.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
Set-PSDebug -Strict
Set-StrictMode -Version Latest
# Confirm whether device is activated already.
if (!(Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "Name like 'Windows%' and PartialProductKey like '%' and LicenseStatus = 1"))
{
    # Activate if key is found.
    if (($key = Get-CimInstance -ClassName SoftwareLicensingService | Select-Object -ExpandProperty OA3xOriginalProductKey))
    {
        & changepk.exe /ProductKey $key 2>&1
        Write-Host "Successfully changed product key to '$key' as retrieved from 'OA3xOriginalProductKey' field."
    }
    else
    {
        throw "Device could not be activated as there isn't a Product Key in 'OA3xOriginalProductKey' field to activate with."
    }
}
else
{
    Write-Host "Device is already activated."
}

