 Install-Module -Name Az -AllowClobber
 import-module -Name Az

$Credential = Get-Credential -Credential "admin@M365x61941857.onmicrosoft.com"
Connect-AzAccount -Credential $Credential

$VMFile = "C:\tools\azure VM\TempAzureVMs.txt"
$ReportFile = "C:\tools\azure VM\TempVMStartReport.CSV"

#start
Foreach ($ThisVMNow in Get-Content "$VMFile")
{

$Error.Clear()

Start-AzVM -ResourceGroupName "cm1" -Name "$ThisVMNow" -nowait
IF ($Error.Count -ne 0)
{

$STR = "Azure Vitual Machine was Started : " + $ThisVMNow
Add-Content $ReportFile $STR
}
else
{

$STR = "ERROR: Failed to start Azure Virtual Machine : " + $ThisVMNow+","+$Error[0]
Add-Content $ReportFile $STR
}
}

#stop
Foreach ($ThisVMNow in Get-Content "$VMFile")
{

$Error.Clear()
Stop-azvm -ResourceGroupName "cm1" -Name "$ThisVMNow" -nowait
IF ($Error.Count -ne 0)
{
$STR = "Azure Virtual Machine was stopped : " + $ThisVMNow
Add-Content $ReportFile $STR
}
else
{
$STR = "ERROR: Failed to stop Azure Virtual Machine : " + $ThisVMNow+","+$Error[0]
Add-Content $ReportFile $STR
}
}
