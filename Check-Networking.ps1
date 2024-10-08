# Run this as Administrator in PowerShell

# Define the VM name
$VMName = "UbuntuVM"

# Check if the VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Error "VM '$VMName' not found. Please check the VM name and try again."
    exit
}

# Get the current switch configuration
$currentSwitch = Get-VMNetworkAdapter -VMName $VMName | Select-Object -ExpandProperty SwitchName
if ($currentSwitch) {
    Write-Host "Current switch for $VMName`: $currentSwitch"
} else {
    Write-Host "No network adapter found for $VMName"
}

# List all available switches
Write-Host "`nAvailable switches:"
Get-VMSwitch | Format-Table Name, SwitchType

# Get detailed network adapter information for the VM
Write-Host "`nDetailed network adapter information for $VMName`:"
Get-VMNetworkAdapter -VMName $VMName | Format-List Name, IsManagementOs, SwitchName, MacAddress, IpAddresses, Status
