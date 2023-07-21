# Replace 'path\to\devices.csv' with the actual path to your CSV file containing the list of devices.
$devices = Get-Content 'C:\Temp\devices-citrix.csv'

$CitrixAtt = @{
    AdminAddress   = "DDC Server name"
    SessionState   = "Active"
    MaxRecordCount = 5000
}

$credential = Get-Credential

foreach ($device in $devices) {
    
    $filterExpression = "SessionState -eq 'Active' -and ClientName -eq '$device'"
    # Use Get-BrokerSession to check if there's an active session for the current device.
    $activeSession = Get-BrokerSession @CitrixAtt -Filter $filterExpression  

    # Output the result for the current device.
    if ($activeSession) {
        Write-Output "Active session found for device: $device"
        
    }
    else {
        Write-Output "No active session found for device: $device"
        if (Test-Connection -ComputerName $device -Count 1 -Quiet) {
            Write-Host "Sending restart command to $device..."
            Restart-Computer -ComputerName $device -Force -Credential $credential 
        }
        else {
            Write-Host "Unable to connect to $device. Skipping restart."
        
        }
    }
}
