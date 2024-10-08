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
