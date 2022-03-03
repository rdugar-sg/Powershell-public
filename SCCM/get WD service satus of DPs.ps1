$Computers = get-content C:\TEMP\servers.txt
$Service = "WDSServer"

foreach ($computer in $computers) {
   $computer 

   $Servicestatus = get-service -name $Service -ComputerName $computer
   $Servicestatus | select-object Name,Status,MachineName | format-table -Autosize

}
