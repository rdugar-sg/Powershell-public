$x=Get-CMDistributionPoint |select networkospath |foreach {($_.NetworkOSPath).replace("\\","")} 
$x |foreach{

#Write-Output $_

$y=Get-WmiObject Win32_OperatingSystem -computername $_ -ea stop


if ($y.version -gt "6.2")
{
#Write-Output $y.version
Write-Output $_


Install-WindowsFeature -ComputerName $_ -Name fs-data-deduplication

}
}