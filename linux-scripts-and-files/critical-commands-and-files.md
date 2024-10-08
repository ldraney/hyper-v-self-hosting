# Critical Ubuntu Network Configuration Files and Commands

## 1. Netplan Configuration File

### File Location
```
/etc/netplan/01-netcfg.yaml
```

### File Content
```yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.0.10/24
      routes:
        - to: default
          via: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

### Commands to Apply Changes
```bash
# Apply Netplan changes
sudo netplan apply

# If changes don't take effect immediately, try generating and applying
sudo netplan generate
sudo netplan apply
```

## 2. Network Manager Configuration

While we didn't directly modify Network Manager files, we ensured it was running and managing our network interface.

### Command to Check Status
```bash
systemctl status NetworkManager
```

### Command to Restart Network Manager
```bash
sudo systemctl restart NetworkManager
```

## 3. Resolv.conf (DNS Configuration)

We didn't directly modify this file, but it's worth checking to ensure proper DNS configuration.

### File Location
```
/etc/resolv.conf
```

### Command to View Content
```bash
cat /etc/resolv.conf
```

### Note
If you need to modify DNS settings, it's best to do it through Netplan configuration and then apply the changes.

## 4. Network Interface Configuration

While not a file, we frequently checked the network interface configuration.

### Command to View Configuration
```bash
ip addr show eth0
```

### Command to View Routing Table
```bash
ip route
```

## Additional Important Commands

```bash
# Set correct permissions for Netplan configuration files
sudo chmod 600 /etc/netplan/*.yaml

# Restart networking service (use with caution, may disrupt connections)
sudo systemctl restart networking

# Test network connectivity
ping 192.168.0.1
ping 8.8.8.8
```

Remember, after making changes to network configurations, it's often a good idea to reboot the system to ensure all changes take effect consistently:

```bash
sudo reboot
```

These files and commands were crucial in diagnosing and resolving our network configuration issues in Ubuntu running as a Hyper-V virtual machine.
