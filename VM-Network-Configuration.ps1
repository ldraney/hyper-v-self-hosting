# Run this script as Administrator

$VMName = "UbuntuVM"
$ExternalSwitchName = "ExternalSwitch"

# Function to create external switch
function New-ExternalSwitch {
    param (
        [string]$SwitchName
    )
    try {
        $netAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Hyper-V*"} | Select-Object -First 1
        New-VMSwitch -Name $SwitchName -NetAdapterName $netAdapter.Name -AllowManagementOS $true -Notes "External Switch for VMs"
        Write-Host "Created new external switch: $SwitchName"
    }
    catch {
        Write-Error "Failed to create external switch: $_"
        return $false
    }
    return $true
}

# Check if external switch exists, create if not
if (-not (Get-VMSwitch -Name $ExternalSwitchName -ErrorAction SilentlyContinue)) {
    if (-not (New-ExternalSwitch -SwitchName $ExternalSwitchName)) {
        exit
    }
}

# Reconfigure VM to use the external switch
try {
    Stop-VM -Name $VMName -Force
    Connect-VMNetworkAdapter -VMName $VMName -SwitchName $ExternalSwitchName
    Start-VM -Name $VMName
    Write-Host "Reconfigured $VMName to use $ExternalSwitchName"
}
catch {
    Write-Error "Failed to reconfigure VM network: $_"
    # Attempt to rollback to the original switch
    try {
        Connect-VMNetworkAdapter -VMName $VMName -SwitchName "UbuntuSwitch"
        Start-VM -Name $VMName
        Write-Host "Rolled back to original switch configuration"
    }
    catch {
        Write-Error "Failed to rollback network configuration: $_"
    }
    exit
}

# Verify network configuration
$vmNetAdapter = Get-VMNetworkAdapter -VMName $VMName
if ($vmNetAdapter.SwitchName -eq $ExternalSwitchName) {
    Write-Host "VM network configuration verified. Using switch: $ExternalSwitchName"
} else {
    Write-Error "VM network configuration verification failed. Current switch: $($vmNetAdapter.SwitchName)"
}
