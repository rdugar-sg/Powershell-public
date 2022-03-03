





# Uncomment the line below if running in an environment where script signing is 
# required.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Site configuration
$SiteCode = "" # Site code 
$ProviderMachineName = "" # SMS Provider machine name
$siteSErver=""

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
     #Change 'CM0' to your site code

$ts = $TS = Get-WmiObject -Class SMS_TaskSequencePackage -ComputerName $siteSErver -Namespace "root\sms\site_"+ $SiteCode | Where-Object {$_.Name -notlike "win10-1709"}

foreach ($t in $ts){


write-host $t.name
     $path = "G:\TaskSequenceBackups"
     $d=Get-Date -Format ddmmyyyy
     $exportname = $t.Name + "_" +$d +".zip"

     
Export-CMTaskSequence  -Name $t.Name -ExportFilePath "G:\Sources$\TaskSequenceBackups\$exportname"
     }