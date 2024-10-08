param(
    [switch]$TestMode,
    [switch]$DryRun,
    [string]$ISOPath = "C:\Users\drane\Downloads\ubuntu-24.04.1-desktop-amd64.iso"
)

# Define variables
$VMName = "UbuntuVM"
$VHDPath = "C:\VMs\UbuntuVM.vhdx"
$VMSwitch = "UbuntuSwitch"
$VHDSize = if ($TestMode) { 1GB } else { 60GB }
$MemoryStartupBytes = if ($TestMode) { 1GB } else { 4GB }

# Function to check if Hyper-V is enabled
function Test-HyperV {
    $hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
    return $hyperv.State -eq "Enabled"
}

# Function to remove VM and associated resources
function Remove-VMAndResources {
    param (
        [string]$Name
    )
    $vm = Get-VM -Name $Name -ErrorAction SilentlyContinue
    if ($vm) {
        if ($vm.State -eq 'Running') {
            Stop-VM -Name $Name -TurnOff -Force
        }
        Remove-VM -Name $Name -Force
        Write-Output "Removed VM: $Name"
    }
    Get-ChildItem -Path "C:\VMs" -Filter "*.vhdx" | ForEach-Object {
        Remove-Item -Path $_.FullName -Force
        Write-Output "Removed VHD: $($_.FullName)"
    }
}

# Function to clean up environment
function Clear-Environment {
    Write-Output "Performing thorough cleanup..."
    Get-VM | ForEach-Object { Remove-VMAndResources -Name $_.Name }
    Get-VMSwitch | Where-Object { $_.Name -eq $VMSwitch } | ForEach-Object {
        Remove-VMSwitch -Name $_.Name -Force
        Write-Output "Removed virtual switch: $($_.Name)"
    }
}

# Function to create virtual switch
function New-CustomVMSwitch {
    try {
        New-VMSwitch -Name $VMSwitch -SwitchType Internal
        Write-Output "Created new virtual switch: $VMSwitch"
    }
    catch {
        Write-Error "Failed to create virtual switch: $_"
        exit
    }
}

# Function to create and configure VM
function New-CustomVM {
    if (-not (Test-Path $ISOPath)) {
        Write-Error "ISO file not found at $ISOPath. Cannot create VM without ISO."
        exit
    }

    try {
        $newVM = New-VM -Name $VMName -MemoryStartupBytes $MemoryStartupBytes -Generation 2 -NewVHDPath $VHDPath -NewVHDSizeBytes $VHDSize -SwitchName $VMSwitch -ErrorAction Stop
        Write-Output "Successfully created new VM: $VMName"
        
        Set-VMFirmware -VMName $VMName -EnableSecureBoot On -SecureBootTemplate "MicrosoftUEFICertificateAuthority"
        Set-VM -Name $VMName -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 1GB -MemoryMaximumBytes 8GB
        
        Add-VMDvdDrive -VMName $VMName -Path $ISOPath
        $DVDDrive = Get-VMDvdDrive -VMName $VMName
        Set-VMFirmware -VMName $VMName -FirstBootDevice $DVDDrive
        Write-Output "Attached ISO: $ISOPath"
        
        Write-Output "Successfully configured VM: $VMName"
    }
    catch {
        Write-Error "Failed to create or configure VM: $_"
        exit
    }
}

# Main execution
if (-not (Test-HyperV)) {
    Write-Error "Hyper-V is not enabled on this system. Please enable Hyper-V and try again."
    exit
}

if (-not (Test-Path $ISOPath)) {
    Write-Error "ISO file not found at $ISOPath. Cannot proceed without a valid ISO."
    exit
}

if ($DryRun) {
    Write-Output "Dry run mode. The following operations would be performed:"
    Write-Output "1. Clear environment (remove existing VMs and switches)"
    Write-Output "2. Create new virtual switch: $VMSwitch"
    Write-Output "3. Create new VM: $VMName with VHD size $VHDSize and memory $MemoryStartupBytes"
    Write-Output "4. Attach ISO: $ISOPath"
    exit
}

Clear-Environment
New-CustomVMSwitch
New-CustomVM

if (-not $TestMode) {
    # Start the VM and wait for IP only in full mode
    Start-VM -Name $VMName
    Write-Output "Started VM: $VMName"
    
    # Wait for IP address (with timeout)
    $timeout = 300
    $timer = [Diagnostics.Stopwatch]::StartNew()
    while (($timer.Elapsed.TotalSeconds -lt $timeout) -and (-not ($ip = (Get-VMNetworkAdapter -VMName $VMName).IPAddresses | Where-Object { $_ -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' } | Select-Object -First 1))) {
        Start-Sleep -Seconds 5
    }
    $timer.Stop()
    
    if ($ip) {
        Write-Output "VM '$VMName' is running. IP address: $ip"
    } else {
        Write-Output "VM '$VMName' is running, but no IP address was detected within the timeout period."
    }
}

Write-Output "Script completed. Final VM state:"
Get-VM -Name $VMName | Format-Table Name, State
