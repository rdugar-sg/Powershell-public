#this exports all Applications in well-formed html table

$UTF8_NO_BOM = New-Object System.Text.UTF8Encoding $False



$a = @()


$apps=Get-CMApplication
foreach($app in $apps)
{

[xml]$xml=$app.SDMPackageXML



  $myobj = New-Object -TypeName PSObject
Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Application' -Value $xml.AppMgmtDigest.Application.DisplayInfo.info.title

Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'CommandLine' -Value  $xml.AppMgmtDigest.DeploymentType.Installer.CustomData.InstallCommandLine
Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Location' -Value  $xml.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location
$xml.AppMgmtDigest.DeploymentType.Installer.CustomData.InstallCommandLine
if ($xml.AppMgmtDigest.DeploymentType.Installer.CustomData.InstallCommandLine.Contains(".bat") -or $xml.AppMgmtDigest.DeploymentType.Installer.CustomData.InstallCommandLine.Contains(".cmd"))
{

 "$($assoc.Id) - $($assoc.Name) - $($assoc.Owner)"
$fp1= $xml.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location.Trim('"') 
if($fp1 -is [system.array]){$fp1=$fp1[0]}
#$fp1=$fp1[0]



$fp2=$xml.AppMgmtDigest.DeploymentType.Installer.CustomData.InstallCommandLine.Trim('"')
$fp=$fp1+$fp2
Write-Host $fp
 ($file = "Filesystem::$fp")


$y=Get-Content -Path $file  -Encoding UTF8 -Raw
Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'scriptcontent' -Value $y

}


  Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Description' -Value $xml.AppMgmtDigest.Application.DisplayInfo.Info.description
  

   Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Owner' -Value $xml.AppMgmtDigest.Application.Owners.User.Id
    Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'SupportContact' -Value $xml.AppMgmtDigest.Application.Contacts.User.Id

   # Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'SupportContact' -Value $xml.AppMgmtDigest.Application.Contacts.User.Id
    
    
    #if ($app.CategoryInstance_UniqueIDs -like '*2dfa8fb4-33b1-45dd-be8f-c2fa618f4737*' ){$cat="NoLeanIX"}else{ $Cat=""}
    $strx=""
   
     Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Vendor' -Value $app.Manufacturer
        Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Version' -Value $app.SoftwareVersion
        Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'DateLastModified' -Value $app.DateLastModified
         Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'modifiedBy' -Value $app.LastModifiedBy
         Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'DateCreated' -Value $app.DateCreated
         Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'CreatedBy' -Value $app.CreatedBy
       
       Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'IsExpired' -Value $app.IsExpired
       Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'IsDeployed' -Value $app.IsDeployed
       Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'CI_ID' -Value $app.CI_ID
        
        foreach ($str in $app.LocalizedCategoryInstanceNames){
        
        $strx=$strx + $str+ "," 
        
        }



        
    

 Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Category' -value $strx
 

 

  $a += $myobj


}



Function GetMessage()

 {


 $text=$_.scriptcontent
 write-host $text
 return $text;

 }





$a |ForEach-Object{
		$_.Description = $_.Description -replace "\n", ' '
		$_  # output the record
	} |	export-csv -Path c:\temp\apps.csv





$h  = '<style>
td {width:100px; max-width:3500px; background-color:lightgrey;}
table {width:100%;}
th {font-size:14pt;background-color:yellow;}
</style>
<title>HTML TABLE</title>
'

#$a | Select 'Description', @{l='Notes';e={$_.Notes -replace "`n"," "}}, E-mail | Export-Csv 'C:\file.csv' -NoTypeInformation -Delimiter ';'
($a | Select-Object Application,CI_ID,Description,Owner,DateLastModified,modifiedBy,DateCreated,CreatedBy,SupportContact,Vendor,Category,IsExpired,IsDeployed,Version,Location,CommandLine,@{Name="scriptcontent";Expression={GetMessage($_)}} |ConvertTo-Html -As TABLE)  -replace '(?m)\s+$', "`r`n<BR>" |Out-File "C:\temp\apps.html"
$h=(Get-Content "C:\temp\apps.html"   -Encoding UTF8 -Raw) -replace ('<title>HTML TABLE</title>',$h) |Set-Content "C:\temp\apps.html"



