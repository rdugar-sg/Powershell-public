<#
.SYNOPSIS
    backup Conditional Access Policies from JSON files
.DESCRIPTION
    This script creates JSON files in a folder to create new Conditional Access Policies.
.EXAMPLE
    .\BackupCA -BackupPath c:\CAP\ 
.PARAMETER BackupPath
    Path to the JSON files.
#>




param(
    [parameter()]
    [String]$BackupPath
)
# Connect to Azure AD
#Connect-AzureAD

$AllPolicies = Get-AzureADMSConditionalAccessPolicy

foreach ($Policy in $AllPolicies) {
    Write-Output "Backing up $($Policy.DisplayName)"
    $PolicyJSON = $Policy | ConvertTo-Json -Depth 6
    $PolicyJSON | Out-File "$BackupPath\$($Policy.Id).json"
}
