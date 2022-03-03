
#erstellt von: Philipp Schindler
# this script creates multiple SW-Groups int multiple OU in a special environment and creates a SCCM Device collection that conected to the AD Group

#skript erstellt Deployment & Collection in SCCM. Außerdem werden die entprechenden AD-Gruppen angelegt

#Parameter
param (
    [Parameter(Mandatory=$true,HelpMessage="name of the application")]
    [ValidateNotnullorEmpty()]
    [string]$appname,

    [Parameter(Mandatory=$true,HelpMessage="either 'SW', 'SW CAD' or 'SW CAE'")]
    [ValidateSet("SW", "SW CAD", "SW CAE")]
    [string]$prefix,

    [Parameter(Mandatory=$true,HelpMessage="'country code or 'LOC' for all sites")]
    [ValidateNotNullOrEmpty()]
    [string]$country

   
    [Parameter(Mandatory=$true,HelpMessage="'to shich DP the content should be deployed")]
    [ValidateNotNullOrEmpty()]
    [string]$DPNAME
)

#$appname="Autodesk DWG TrueView"       #exakter Name der Applikation
#$prefix="SW CAD"            #prefix, either "SW" or "SW CAD"
#$country="UK"               #Länderkürzel bzw "LOC" für alle

Write-Output "You have entered the following parameters:"
Write-Output "appname:  $appname"
Write-Output "prefix:   $prefix"
Write-Output "country:  $country"

Pause

$nameglb="GLB" + " " + $prefix + " " + $appname
$snameglb=$nameglb -replace " ",""

Write-Output "create $snameglb"

#$glbgrp=New-ADGroup -Name $nameglb -SamAccountName $snameglb -GroupCategory Security -GroupScope Global -DisplayName $nameglb -Path "OU=Groups,OU=GLB,DC=ekgroup,DC=org"  -Description $nameglb  -ManagedBy "CN=adm - SW Admins GLB,OU=Admin Groups,OU=GLB,DC=ekgroup,DC=org"

#set Manager can update MembershipList
$sid=(Get-ADGroup "CN=adm - SW Admins GLB,OU=Admin Groups,OU=GLB,DC=ekgroup,DC=org").sid
$Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($sid, [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty, [System.Security.AccessControl.AccessControlType]::Allow,[Guid]"bf9679c0-0de6-11d0-a285-00aa003049e2")
$ACL=Get-Acl ("AD:\"+"CN=$nameglb,OU=Groups,OU=GLB,DC=ekgroup,DC=org")

$acl.AddAccessRule($Rule)
Set-Acl -Path ("AD:\"+"CN=$nameglb,OU=Groups,OU=GLB,DC=ekgroup,DC=org") -AclObject $ACL
#end


$OUList=Get-ADOrganizationalUnit -Filter *  -SearchBase "OU=LOC,DC=ekgroup,DC=org" |Where-Object { ($_.DistinguishedName -like '*Groups*') -and ($_.DistinguishedName -like "*OU=$country*") }  
ForEach($ou in $OUList)
{

    $ar=$ou.DistinguishedName -split ","
    $loc=$ar[1].Remove(0,3)

    #$ar |Out-GridView

    #if ($loc -eq "RTL") {

        $ctry=$ar[2].Remove(0,3)

        $name=$loc + " " + $prefix + " " + $appname

        $sname=$name -replace " ",""

        Write-Output "create $name"

        Write-Output "create $ctry"
        Write-Output "create $loc"
        Write-Output "CN=adm - SW Admins $ctry$loc,OU=Admin Groups,OU=GLB,DC=ekgroup,DC=org"

        #$locgrp=New-ADGroup -Name $name -SamAccountName $sname.Trim() -GroupCategory Security -GroupScope Global -DisplayName $name -Path $ou.DistinguishedName  -Description "$appname Device Deployment Group" -ManagedBy "CN=adm - SW Admins $ctry$loc,OU=Admin Groups,OU=GLB,DC=ekgroup,DC=org"

        #set Manager can update MembershipList
        $sid=(Get-ADGroup "CN=adm - SW Admins $ctry$loc,OU=Admin Groups,OU=GLB,DC=ekgroup,DC=org").sid
        $Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($sid, [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty, [System.Security.AccessControl.AccessControlType]::Allow,[Guid]"bf9679c0-0de6-11d0-a285-00aa003049e2")
        $ACL=Get-Acl ("AD:\"+"CN=$name,OU=Groups,OU=$LOC,OU=$CTRY,OU=LOC,DC=ekgroup,DC=org")

        $acl.AddAccessRule($Rule)
        Set-Acl -Path ("AD:\"+"CN=$name,OU=Groups,OU=$LOC,OU=$CTRY,OU=LOC,DC=ekgroup,DC=org") -AclObject $ACL
        #end

        $childgroup = Get-ADgroup -Identity "CN=$name,$ou"
        $parentGroup = Get-ADGroup -Identity "CN=$nameglb,OU=Groups,OU=GLB,DC=ekgroup,DC=org"

        Write-Output "Add $name To $nameglb"
        Add-ADGroupMember -Identity $parentGroup -Members $childgroup
    #}

}

#Exit #(when only AD-Groups should be created)

Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
Set-Location "EKS:" # Set the current location to be the site code.

#Create Collection
Write-Output "Create Collection"
$y=New-CMDeviceCollection -Name "$appName" -Comment $appName -LimitingCollectionName "Base All Systems"  -RefreshType Periodic -RefreshSchedule (New-CMSchedule -Start (get-date) -RecurInterval Days -RecurCount 7) -Verbose
#Collection in Ordner verschieben
Write-Output "Collection in Ordner verschieben"
$collFolder="EKS:\devicecollection\NEW GENERATION"
Move-CMObject -FolderPath $collFolder -InputObject $y -verbose

Add-CMDeviceCollectionQueryMembershipRule -CollectionName $appName -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemGroupName = `"EK\\$nameglb`"" -RuleName $appname

#Exit #(when only device collection should be created)

#distribute Content
Write-Output "Distribute Content"
Start-CMContentDistribution -ApplicationName $appName -DistributionPointName $DPNAME -Verbose 



#start Deployment
Write-Output "Create Deployment"


#$dtime=Get-Date -Format "M/d/yyyy HH:mm"


Start-CMApplicationDeployment -CollectionName $appName -Name $appName -DeployAction Install -DeployPurpose Required -UserNotification DisplaySoftwareCenterOnly -AvailableDateTime "$(Get-Date -Format "M/d/yyyy HH:mm")" -Verbose



