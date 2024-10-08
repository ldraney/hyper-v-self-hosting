# Hyper-V Network Troubleshooting Summary

## Key to Success

The primary issue was that the Ubuntu VM was connected to the wrong virtual switch. By changing the VM's network adapter to use the correctly configured `UbuntuSwitch`, we established the proper network connection.

## Steps to Resolution

1. Verified Hyper-V switch configurations
2. Checked host and VM network adapter settings
3. Confirmed NAT configuration
4. Identified the mismatch between VM network adapter and the intended switch
5. Connected the VM to the correct virtual switch (UbuntuSwitch)

## Commands Used

### PowerShell Commands (Windows Host)

```powershell
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
```

### Bash Commands (Ubuntu VM)

```bash
# Check Network Interface Configuration
ip addr show eth0

# View Routing Table
ip route

# Test Network Connectivity
ping 192.168.0.1
ping 8.8.8.8

# Display Network Manager Status
systemctl status NetworkManager

# View Netplan Configuration
cat /etc/netplan/*.yaml

# Apply Netplan Changes
sudo netplan apply

# Restart Network Manager
sudo systemctl restart NetworkManager

# Set Correct File Permissions for Netplan Config
sudo chmod 600 /etc/netplan/*.yaml
```

## Conclusion

The key to resolving this issue was methodically checking each component of the network configuration, from the Hyper-V switch settings on the host to the network configuration within the VM. By identifying that the VM was connected to the wrong switch and correcting this, we established the proper network connection.
