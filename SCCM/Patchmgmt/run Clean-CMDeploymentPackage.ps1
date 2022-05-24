#D:\scripts\Patchmgmt\Clean-CMDeploymentPackage.ps1 -SiteServer "detvmsccm3" -PackageID "eks002fc" -expiredUpdates -ShowProgress -Verbose

Get-CMSoftwareUpdateDeploymentPackage


$x=Get-CMSoftwareUpdateDeploymentPackage  |select packageid

 foreach ($pk in $x) {

 write-host $pk.packageid

D:\scripts\Patchmgmt\Clean-CMDeploymentPackage.ps1 -SiteServer "detvmsccm3" -PackageID $pk.packageid -expiredUpdates -ShowProgress -Verbose
}