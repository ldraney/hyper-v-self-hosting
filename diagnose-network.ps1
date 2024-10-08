# List Hyper-V Switches
Get-VMSwitch | Format-List Name, SwitchType, NetAdapterInterfaceDescription

# Check Host IP Configuration for UbuntuSwitch
Get-NetIPAddress -InterfaceAlias "*UbuntuSwitch*" | Format-List IPAddress, PrefixLength

# Verify NAT Configuration
Get-NetNat | Format-List Name, InternalIPInterfaceAddressPrefix

# Ping VM from Host
ping 192.168.0.10

# List Hyper-V Network Adapters
Get-NetAdapter | Where-Object {$_.InterfaceDescription -like "*Hyper-V*"} | Format-List Name, InterfaceDescription, Status, MacAddress

# Check VM Network Adapter
Get-VMNetworkAdapter -VMName "UbuntuVM"

# View ARP Table
arp -a

# Check Windows Defender Firewall Rules for Hyper-V
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Hyper-V*" -and $_.Enabled -eq $true} | Format-Table DisplayName, Direction, Action
