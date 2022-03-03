#this copies boot image drivers
#by Philipp Schindler
#

#requirements: RSAT installed for using get-GPOReport


#parameter
$domain="example.domain.com"
$DC="exampleDC"
$OU = "OU=test,OU=one,DC=test,DC=com"


#start

Get-ADOrganizationalUnit $OU
$LinkedGPOs = Get-ADOrganizationalUnit $OU | Select-object -ExpandProperty LinkedGroupPolicyObjects
$LinkedGPOGUIDs = $LinkedGPOs | ForEach-object{$_.Substring(4,36)}
$LinkedGPOGUIDs | ForEach-object {

$gpo=Get-GPO -Guid $_

write-host $gpo.DisplayName
$path='C:\scripts\' + $gpo.DisplayName + '.xml'
write-host $path

Get-GPOReport -Name $gpo.DisplayName -Domain $domain -Server $dc -ReportType XML -Path $path -Verbose


}