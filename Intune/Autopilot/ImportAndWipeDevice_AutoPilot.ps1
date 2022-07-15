<#
.SYNOPSIS
    Enable Autopilot the automated way
.DESCRIPTION
	 Updloads a Device to Intune and generates a csv with the Hardware ID. And wipes the devie to start the Autopilot-process
 
.NOTES
    FileName:    ImportAndWipeDevice_AutoPilot.ps1
	   Author:      Maurice Daly
    Github:      https://github.com/Philinger1
    Created:     2022-07-15
   
    
    Version history:
	1.0

#inspired by Maurice Daly: https://call4cloud.nl/2020/04/wipe-your-device-script-without-intune/
#>

#1. Reset Device WMI PART
#MDM WMI Bridge part


#customize line 40 tenantname 
#customize line 42 if you whish to copy the HWID somewhere



$reset =
@'
$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_RemoteWipe"
$methodName = "doWipeMethod"
$session = New-CimSession
$params = New-Object Microsoft.Management.Infrastructure.CimMethodParametersCollection
$param = [Microsoft.Management.Infrastructure.CimMethodParameter]::Create("param", "", "String", "In")
$params.Add($param)
$instance = Get-CimInstance -Namespace $namespaceName -ClassName $className -Filter "ParentID='./Vendor/MSFT' and InstanceID='RemoteWipe'"
$session.InvokeMethod($namespaceName, $instance, $methodName, $params)
'@
#2. Autopilot Export and Email the CSV


$start =
@'
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference= 'silentlycontinue'
$OriginalPref = $ProgressPreference
New-Item -Path c:\programdata\customscripts -ItemType Directory -Force -Confirm:$false | out-null
install-packageprovider -name nuget -minimumversion 2.8.5.201 -force | out-null
Save-Script -Name Get-WindowsAutoPilotInfo -Path c:\ProgramData\CustomScripts -force | out-null
Save-Script -Name Upload-WindowsAutopilotDeviceInfo -Path c:\ProgramData\CustomScripts -force | out-null
 Install-Module -Name AzureAD -Force -ErrorAction Stop -Confirm:$false -Verbose:$false
 Install-Module -Name PSIntuneAuth -Scope AllUsers -Force -ErrorAction Stop -Confirm:$false -Verbose:$false


#Autopilot Info Uploaden
C:\ProgramData\CustomScripts\Upload-WindowsAutopilotDeviceInfo.ps1 -TenantName $tenantname # -GroupTag "AADUserDriven" -Verbose
start-sleep -s 10
$PCName = $env:COMPUTERNAME
c:\ProgramData\CustomScripts\Get-WindowsAutoPilotInfo.ps1 -OutputFile c:\ProgramData\CustomScripts\$PCName.csv
 #Copy-Item c:\ProgramData\CustomScripts\$PCName.csv \\cm1\c$\test
#Start PowerShell session as system
Start-Process -FilePath "c:\ProgramData\CustomScripts\pstools\psexec.exe" -windowstyle hidden -ArgumentList '-i -s cmd /c C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -file c:\programdata\customscripts\reset.ps1'
'@



#3. Downloading Sysinternals and Starting the script as system

##############md customscripts
md $env:ProgramData\CustomScripts\

#Export script to programdata folder
Out-File -FilePath $(Join-Path $env:ProgramData CustomScripts\reset.ps1) -Encoding unicode -Force -InputObject $reset -Confirm:$false
Out-File -FilePath $(Join-Path $env:ProgramData CustomScripts\start.ps1) -Encoding unicode -Force -InputObject $start -Confirm:$false

#Accepteula Psexec

reg.exe ADD HKCU\Software\Sysinternals /v EulaAccepted /t REG_DWORD /d 1 /f | out-null

#Sysinternals download part
invoke-webrequest -uri: "https://download.sysinternals.com/files/SysinternalsSuite.zip" -outfile "c:\programdata\customscripts\pstools.zip" | out-null
Expand-Archive c:\programdata\customscripts\pstools.zip -DestinationPath c:\programdata\customscripts\pstools -force | out-null

#Start Powershell Script as Admin
Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-noprofile -ExecutionPolicy Bypass -file c:\programdata\customscripts\start.ps1" -Verb RunAs
