# Option 1: Using Hyper-V Manager
# 1. Open Hyper-V Manager
# 2. Right-click on your VM (UbuntuVM) and select "Connect"
# 3. In the VM connection window, click "Start" if the VM isn't running
# 4. Follow the Ubuntu installation prompts

# Option 2: Using PowerShell
# First, ensure you're running PowerShell as Administrator

# Start the VM if it's not already running
$VMName = "UbuntuVM"

if ((Get-VM -Name $VMName).State -ne "Running") {
    Start-VM -Name $VMName
    Write-Host "Started VM: $VMName"
}

# Connect to the VM console
try {
    vmconnect.exe localhost $VMName
    Write-Host "Connected to VM console. Please complete the Ubuntu installation."
}
catch {
    Write-Error "Failed to connect to VM console: $_"
    exit
}

# Wait for the VM to be ready (this is a simple check, might need adjustment)
do {
    $heartbeat = (Get-VMIntegrationService -VMName $VMName | Where-Object { $_.Name -eq "Heartbeat" }).PrimaryStatusDescription
    Start-Sleep -Seconds 5
} while ($heartbeat -ne "OK")

Write-Host "VM is ready. Please complete the Ubuntu installation and initial setup."

# After setup, you may want to restart the VM
Restart-VM -Name $VMName -Force
Write-Host "VM has been restarted."
