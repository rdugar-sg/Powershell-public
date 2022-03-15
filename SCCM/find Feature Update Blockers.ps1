$collectionname=""



# Site configuration
$SiteCode = "" # Site code 
$ProviderMachineName = "" # SMS Provider machine name

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




Function Test-ConnectionQuietFast {
    [CmdletBinding()]
    param(
        [String]$ComputerName,
        [int]$Count = 1,
        [int]$Delay = 500
    )

    for($I = 1; $I -lt $Count + 1 ; $i++)
    {
        Write-Verbose "Ping Computer: $ComputerName, $I try with delay $Delay milliseconds"

        # Test the connection quiet to the computer with one ping
        If (Test-Connection -ComputerName $ComputerName -Quiet -Count 1)
        {
            # Computer can be contacted, return $True
            Write-Verbose "Computer: $ComputerName is alive! With $I ping tries and a delay of $Delay milliseconds"
            return $True
        }

        # delay between each pings
        Start-Sleep -Milliseconds $Delay
    }

    # Computer cannot be contacted, return $False
    Write-Verbose "Computer: $ComputerName cannot be contacted! With $Count ping tries and a delay of $Delay milliseconds"
    $False
}


$allBlockers = @()


$computers=Get-CMCollectionMember -CollectionName $collectionname

$varFromSession= @()

foreach ($computer  in $computers){

write-host $computer.Name


if (Test-ConnectionQuietFast -ComputerName $computer.name -Count 1 -Delay 150){





$varFromSession+=Invoke-Command -Computername $computer.name -ScriptBlock {

$WmiObject = Get-WmiObject Win32_ComputerSystem | select Manufacturer, Model

$Blockers = @()
$SearchLocation = 'C:\$WINDOWS.~BT\Sources\Panther'

if(Test-Path "$SearchLocation\compat*.xml"){

$CompatibilityXMLs = Get-childitem "$SearchLocation\compat*.xml" | Sort LastWriteTime –Descending

# Create an array to hold the results


# Search each file for any hard blockers
Foreach ($item in $CompatibilityXMLs)
{
    $xml = [xml]::new()
    $xml.Load($item)
    $HardBlocks = $xml.CompatReport.Hardware.HardwareItem | Where {$_.InnerXml -match 'BlockingType="Hard"'}
    If($HardBlocks)
    {
        Foreach ($HardBlock in $HardBlocks)
        {
            $FileAge = (Get-Date).ToUniversalTime() – $item.LastWriteTimeUTC
            $Blockers += [pscustomobject]@{
            Venor=  $wmiobject.Manufacturer
            Model =$wmiobject.Model

                ComputerName = $env:COMPUTERNAME
                FileName = $item.Name
                LastWriteTimeUTC = $item.LastWriteTimeUTC
                FileAge = "$($Fileage.Days) days $($Fileage.hours) hours $($fileage.minutes) minutes"
                BlockingType = $HardBlock.CompatibilityInfo.BlockingType
                Title = $HardBlock.CompatibilityInfo.Title
                Message = $HardBlock.CompatibilityInfo.Message
                BlockDriver=""
                BlockDriverFileName=""
                BlockDriverProvider=""
                BlockDriverManufacurer=""
                 BlockDriverHWDescription=""
            }
        }



    }
}





$SearchLocation = 'C:\$WINDOWS.~BT\Sources\Panther'
$CompatibilityXMLs = Get-childitem "$SearchLocation\compat*.xml" | Sort LastWriteTime –Descending
Foreach ($item in $CompatibilityXMLs)
{
    $xml = [xml]::new()
    $xml.Load($item)
   
       $DriverBlocks = $xml.CompatReport.DriverPackages.DriverPackage |where BlockMigration -eq "True"
      

    If($DriverBlocks)
    {
        Foreach ($DriverBlock in $DriverBlocks)
        {
        try{
        $x=Get-WindowsDriver -Driver $DriverBlock.inf -Online
        }

        catch { 

            $x="nf" }

        if($x -eq "nf"){
        $FileAge = (Get-Date).ToUniversalTime() – $item.LastWriteTimeUTC
            $Blockers += [pscustomobject]@{
                        Venor=  $wmiobject.Manufacturer
            Model =$wmiobject.Model
                ComputerName = $env:COMPUTERNAME
                FileName = $item.Name
                LastWriteTimeUTC = $item.LastWriteTimeUTC
                FileAge = "$($Fileage.Days) days $($Fileage.hours) hours $($fileage.minutes) minutes"
                BlockingType = "DriverBlocking Migration"
                Title = $DriverBlock.inf
                Message ="not found"
                BlockDriver="not found"
                BlockDriverFileName="not found"
                BlockDriverProvider="not found"
                BlockDriverManufacurer="not found"
                 BlockDriverHWDescription="not found"
$x=0
            }



}
        else
        {
        $x= Get-WindowsDriver -Driver $DriverBlock.inf -Online
        #$x

            $FileAge = (Get-Date).ToUniversalTime() – $item.LastWriteTimeUTC
            $Blockers += [pscustomobject]@{
                        Venor=  $wmiobject.Manufacturer
            Model =$wmiobject.Model
                ComputerName = $env:COMPUTERNAME
                FileName = $item.Name
                LastWriteTimeUTC = $item.LastWriteTimeUTC
                FileAge = "$($Fileage.Days) days $($Fileage.hours) hours $($fileage.minutes) minutes"
                BlockingType = "DriverBlocking Migration"
                Title = $DriverBlock.inf
                Message =$x[1].driver 
                BlockDriver=$x[1].driver 
                BlockDriverFileName=$x[1].OriginalFileName
                BlockDriverProvider=$x[1].ProviderName  
                BlockDriverManufacurer=$x[1].ManufacturerName  
                 BlockDriverHWDescription=$x[1].HardwareDescription  
$x=0
            }
      }  }  
 
}
}




# Report results
If ($Blockers)
{


  $varFromSession=$Blockers
  
}
Else
{
$Blockers += [pscustomobject]@{
            Venor=  $wmiobject.Manufacturer
            Model =$wmiobject.Model
                ComputerName = $env:COMPUTERNAME
                FileName = "No hard blockers found"
                LastWriteTimeUTC = "No hard blockers found"
                FileAge = "No hard blockers found"
                BlockingType = "No hard blockers found"
                Title ="No hard blockers found"
                Message ="No hard blockers found"
                BlockDriver="No hard blockers found"
                BlockDriverFileName="No hard blockers found"
                BlockDriverProvider="No hard blockers found"
                BlockDriverManufacurer="No hard blockers found"
                 BlockDriverHWDescription="No hard blockers found"}
 $varFromSession+= $Blockers
  # $varFromSession= "No hard blockers found"
}
}
else{
   $Blockers += [pscustomobject]@{
               Venor=  $wmiobject.Manufacturer
            Model =$wmiobject.Model
                
                ComputerName = $env:COMPUTERNAME
                FileName = "compatfiles not found"
                LastWriteTimeUTC ="compatfiles not found"
                FileAge = "compatfiles not found"
                BlockingType = "Computer or compatfiles not found"
                Title ="compatfiles not found"
                Message ="compatfiles not found"
                BlockDriver="compatfiles not found"
                BlockDriverFileName="compatfiles not found"
                BlockDriverProvider="compatfiles not found"
                BlockDriverManufacurer=" compatfiles not found"
                 BlockDriverHWDescription="compatfiles not found"}
 $varFromSession+= $Blockers


}
 $varFromSession
}





}

else{
 write-host "not online"


}

 
 }
 
 
 $varFromSession | Export-Csv -Path "c:\tempoutfile.csv" -NoTypeInformation
