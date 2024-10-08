# Access-UbuntuVM.ps1

$VMName = "UbuntuVM"
$VMSwitch = "UbuntuSwitch"

# Ensure the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script needs to be run as Administrator. Please restart PowerShell as an Administrator and try again."
    exit
}

# Start the VM if it's not already running
if ((Get-VM -Name $VMName).State -ne "Running") {
    Start-VM -Name $VMName
    Write-Host "Started VM: $VMName"
}

# Connect to the VM console
try {
    vmconnect.exe localhost $VMName
    Write-Host "Connected to VM console. Please complete the Ubuntu installation if not already done."
}
catch {
    Write-Error "Failed to connect to VM console: $_"
    exit
}

# Wait for the VM to be ready
do {
    $heartbeat = (Get-VMIntegrationService -VMName $VMName | Where-Object { $_.Name -eq "Heartbeat" }).PrimaryStatusDescription
    Start-Sleep -Seconds 5
} while ($heartbeat -ne "OK")

Write-Host "VM is ready. Proceeding with network setup."

# Set up NAT network for internet access
$NATNetworkName = "UbuntuNAT"
$NATNetworkPrefix = "192.168.0.0/24"
$NATNetworkGateway = "192.168.0.1"

# Create an internal virtual switch if it doesn't exist
if (-not (Get-VMSwitch -Name $VMSwitch -ErrorAction SilentlyContinue)) {
    New-VMSwitch -Name $VMSwitch -SwitchType Internal
    Write-Host "Created new internal switch: $VMSwitch"
}

# Create a NAT network
if (-not (Get-NetNat -Name $NATNetworkName -ErrorAction SilentlyContinue)) {
    New-NetNat -Name $NATNetworkName -InternalIPInterfaceAddressPrefix $NATNetworkPrefix
    Write-Host "Created new NAT network: $NATNetworkName"
}

# Configure the host's internal network adapter
$HostAdapter = Get-NetAdapter | Where-Object { $_.Name -like "*$VMSwitch*" }
if (-not (Get-NetIPAddress -InterfaceIndex $HostAdapter.ifIndex -IPAddress $NATNetworkGateway -ErrorAction SilentlyContinue)) {
    New-NetIPAddress -IPAddress $NATNetworkGateway -PrefixLength 24 -InterfaceIndex $HostAdapter.ifIndex
    Write-Host "Configured host network adapter with IP: $NATNetworkGateway"
}

# Display VM's current IP address
$VMIP = (Get-VMNetworkAdapter -VMName $VMName).IPAddresses | Where-Object { $_ -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' } | Select-Object -First 1
if ($VMIP) {
    Write-Host "VM's current IP address: $VMIP"
} else {
    Write-Host "VM's IP address not detected. You may need to configure it manually within the VM."
}

Write-Host "Network setup completed. Your Ubuntu VM should now have internet access."
Write-Host "If you haven't already, complete the Ubuntu installation and initial setup in the VM console."
Write-Host "After setup, you may want to restart the VM using: Restart-VM -Name $VMName -Force"
