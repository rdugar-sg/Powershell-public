
#https://learn.microsoft.com/de-de/azure/active-directory/enterprise-users/groups-settings-cmdlets


Install-Module AzureADPreview -AllowClobber
Import-Module AzureADPreview
AzureADPreview\Connect-AzureAD

Get-AzureADDirectorySettingTemplate

$TemplateId = (Get-AzureADDirectorySettingTemplate | where { $_.DisplayName -eq "Group.Unified" }).Id
$Template = Get-AzureADDirectorySettingTemplate | where -Property Id -Value $TemplateId -EQ

$Setting = $Template.CreateDirectorySetting()

$Setting["UsageGuidelinesUrl"] = "https://guideline.example.com"
$Setting["EnableMIPLabels"] = "True"



New-AzureADDirectorySetting -DirectorySetting $Setting

$grpUnifiedSetting = (Get-AzureADDirectorySetting | where -Property DisplayName -Value "Group.Unified" -EQ)
$Setting = $grpUnifiedSetting
$grpUnifiedSetting.Values

Install-Module ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement

Connect-IPPSSession -UserPrincipalName admin@M365x61941857.onmicrosoft.com


Execute-AzureAdLabelSync
