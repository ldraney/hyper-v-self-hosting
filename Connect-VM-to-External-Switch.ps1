# Run this as Administrator in PowerShell
$VMName = "UbuntuVM"
$ExternalSwitchName = "ExternalNetSwitch"

# Stop the VM if it's running
if ((Get-VM -Name $VMName).State -eq 'Running') {
    Stop-VM -Name $VMName -Force
    Write-Host "Stopped VM '$VMName'."
}

# Connect the VM to the new external switch
try {
    Connect-VMNetworkAdapter -VMName $VMName -SwitchName $ExternalSwitchName
    Write-Host "Connected VM '$VMName' to external switch '$ExternalSwitchName'."
} catch {
    Write-Error "Failed to connect VM to external switch: $_"
    exit
}

# Start the VM
Start-VM -Name $VMName
Write-Host "Started VM '$VMName'."
