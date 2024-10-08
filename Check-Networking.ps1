# Run this as Administrator in PowerShell
$VMName = "UbuntuVM"

# Get VM network adapter information
$vmAdapter = Get-VMNetworkAdapter -VMName $VMName
Write-Host "VM Network Adapter Configuration:"
$vmAdapter | Format-List SwitchName, MacAddress, IPAddresses, Status

# Check if the switch is external
$switch = Get-VMSwitch -Name $vmAdapter.SwitchName
Write-Host "`nSwitch Configuration:"
$switch | Format-List Name, SwitchType, NetAdapterInterfaceDescription

# Check the host's network adapter connected to the switch
$hostAdapter = Get-NetAdapter | Where-Object { $_.InterfaceDescription -eq $switch.NetAdapterInterfaceDescription }
Write-Host "`nHost Network Adapter Configuration:"
$hostAdapter | Format-List Name, Status, LinkSpeed, MacAddress

# Check DHCP status on the host adapter
$dhcpStatus = Get-NetIPInterface -InterfaceAlias $hostAdapter.Name -AddressFamily IPv4
Write-Host "`nDHCP Status on Host Adapter:"
$dhcpStatus | Format-List InterfaceAlias, Dhcp
