#this copies boot image drivers
#by Philipp Schindler
#

#requirements: Import-Module ConfigurationManager




#parameter
$from=""
$to=""



Function Copy-BootImageDrivers {
    PARAM (
        $from, $to
    )
 
    $boot = Get-CMBootImage -ID $to
 
    (Get-CMBootImage -Id $from).ReferencedDrivers | ForEach-Object {
        Write-Verbose "Copying $($_.Id) to $($to)"
        Set-CMDriver -Id $_.Id -AddBootImagePackage $boot -UpdateDistributionPointsforBootImagePackage $false
        write-host $_.id
    }
 
}
 
#Example use
Copy-BootImageDrivers -from $from -to $to