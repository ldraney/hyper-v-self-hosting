# Run this as Administrator in PowerShell
$ExternalSwitchName = "ExternalNetSwitch"

# Create the external switch
try {
    New-VMSwitch -Name $ExternalSwitchName -NetAdapterName "Ethernet" -AllowManagementOS $true
    Write-Host "External switch '$ExternalSwitchName' created successfully."
} catch {
    Write-Error "Failed to create external switch: $_"
    exit
}
