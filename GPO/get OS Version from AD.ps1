$AllProperties = $("Name","Enabled","OperatingSystem","OperatingSystemServicePack","OperatingSystemVersion","IPv4Address","LastLogonDate","PasswordLastSet") 
$AllPropertiesPlusBuild = $AllProperties + @{name="OSBuild"; expression={([Version](($_.OperatingSystemVersion -replace " \(",".") -replace "\)",""))}}
$OldOSs = $null
$OperatingSystemVersion = "10.0.18363" #lower than Windows 10 1909

$OldOSs=Get-ADComputer -Filter {OperatingSystem -like "*Windows*" -and OperatingSystem -notlike "*server*" -and OperatingSystem -notlike "*LTSB*" -and OperatingSystem -notlike "*LTSC*"} -Properties $AllProperties | Select-Object $AllPropertiesPlusBuild | ? {$_.OSBuild -lt $OperatingSystemVersion} 

