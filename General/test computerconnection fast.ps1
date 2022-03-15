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


#example 
#if (Test-ConnectionQuietFast -ComputerName $computer.name -Count 1 -Delay 150){
