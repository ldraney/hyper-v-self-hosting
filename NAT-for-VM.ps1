# Variables
$vmName = "UbuntuVM"
$natName = "UbuntuNAT"
$internalSwitchName = "UbuntuSwitch"
$externalSwitchName = "ExternalNetSwitch"
$internalIP = "192.168.0.2"
$gatewayIP = "192.168.0.1"
$subnetMask = 24
$dnsServer = "8.8.8.8"

# Check if the VM's network adapter is connected to the internal switch
$vmNetworkAdapter = Get-VMNetworkAdapter -VMName $vmName | Where-Object { $_.SwitchName -eq $internalSwitchName }

if ($vmNetworkAdapter) {
    # Assign a static IP address to the VM's adapter
    Set-VMNetworkAdapter -VMName $vmName -StaticMacAddress $vmNetworkAdapter.MacAddress
    
    # Configure the IP address, subnet mask, and default gateway inside the VM
    Invoke-Command -VMName $vmName -ScriptBlock {
        # Update network interface settings
        netsh interface ip set address name="Ethernet" static $using:internalIP $using:subnetMask $using:gatewayIP
        netsh interface ip set dns name="Ethernet" static $using:dnsServer
    }
    
    # Verify that NAT is active
    Get-NetNat | Where-Object { $_.Name -eq $natName } | Format-List

    Write-Host "VM network settings have been updated. Check the VM for internet access."
} else {
    Write-Host "VM network adapter is not connected to the internal switch. Please verify the VM configuration."
}

