[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null 
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer(); 
$wsus



$update = $wsus.SearchUpdates(‘KB890830’)

#$update



foreach($up in $update)
{
 $up.Decline()
}



