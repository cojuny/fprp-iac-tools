#!/bin/bash
echo "===== First Boot Configuration ====="

read -p "Enter hostname: " HOSTNAME
read -p "Enter new username: " USERNAME
read -p "Enter static IP (e.g. 192.168.100.201/24): " STATIC_IP

# Detect interface automatically
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')

echo "Using interface: $INTERFACE"

# Set hostname
hostnamectl set-hostname $HOSTNAME

# Create user
useradd -m -s /bin/bash -G sudo $USERNAME
passwd $USERNAME

# Setup SSH key for new user
mkdir -p /home/$USERNAME/.ssh
cat ~/.ssh/id_rsa.pub > /home/$USERNAME/.ssh/authorized_keys
chmod 700 /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

# Configure static IP
cat <<EOF > /etc/netplan/01-static.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      dhcp4: no
      addresses:
        - $STATIC_IP
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

chmod 600 /etc/netplan/01-static.yaml

netplan apply

echo "Configuration complete."

# Enable ssh
ssh-keygen -A
systemctl restart ssh