# Run this as Administrator in PowerShell
$VMName = "UbuntuVM"

# Wait for the VM to get an IP address (timeout after 60 seconds)
$timeout = 60
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $timeout) -and (-not ($vmIP = (Get-VMNetworkAdapter -VMName $VMName).IPAddresses | Where-Object { $_ -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' }))) {
    Start-Sleep -Seconds 5
}
$timer.Stop()

if ($vmIP) {
    Write-Host "VM IP Address: $vmIP"
    
    # Check if the host can ping the VM
    $pingResult = Test-Connection -ComputerName $vmIP -Count 1 -Quiet
    if ($pingResult) {
        Write-Host "Host can successfully ping the VM."
    } else {
        Write-Host "Host cannot ping the VM. This could indicate a firewall or network configuration issue."
    }
} else {
    Write-Host "The VM did not receive an IP address within the timeout period. This could indicate a DHCP or network configuration issue."
}
