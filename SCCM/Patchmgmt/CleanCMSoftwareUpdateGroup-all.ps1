#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '1/12/2018 1:32:52 PM'.

# Uncomment the line below if running in an environment where script signing is 
# required.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Site configuration
$SiteCode = "EKS" # Site code 
$ProviderMachineName = "DETVMSCCM3.ekgroup.org" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams


function SecondTuesday ([int]$Month, [int]$Year) {
    [int]$Day = 1
    while((Get-Date -Day $Day -Hour 0 -Millisecond 0 -Minute 0 -Month $Month -Year $Year -Second 0).DayOfWeek -ne "Tuesday") {
        $day++
    }
    #saturday after 2nd Tuesday
    $day += 3
    return (Get-Date -Day $Day -Hour 0 -Millisecond 0 -Minute 0 -Month $Month -Year $Year -Second 0)
}


if ($today.Date -eq $x.Date){
$y= "ok"


$x=Get-CMSoftwareUpdateGroup |Select-Object LocalizedDisplayName 

    foreach ($sug in $x) {

     Write-Host $sug.LocalizedDisplayName

    D:\scripts\Patchmgmt\CleanCMSoftwareUpdateGroupwithoudRefresh.ps1 -SiteServer detvmsccm3 -SUGName $sug.LocalizedDisplayName -RemoveContent
    }
}
else
{
$y= "no"
}

$y
