#!/bin/bash

# This script disables cloud-init services and prevents cloud-init from configuring the network.
# ------------------------------------------------------------------------------
# How to use:
# 1. Save this script to a file (e.g., disable-cloud-init.sh)
# 2. Make the script executable with the command: chmod +x disable-cloud-init.sh
# 3. Run the script with root privileges: sudo ./disable-cloud-init.sh
# ------------------------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "Create empty file to prevent service from starting..."
sudo mkdir -p /etc/cloud
sudo touch /etc/cloud/cloud-init.disabled

echo "Deselects "-" all services expect the 'None' in /tmp and load..."
echo "cloud-init cloud-init/datasources multiselect None -NoCloud -ConfigDrive -OpenNebula -DigitalOcean -Azure -AltCloud -OVF -MAAS -GCE -OpenStack -CloudSigma -SmartOS -Bigstep -Scaleway -AliYun -Ec2 -CloudStack -Hetzner -IBMCloud -Oracle -Exoscale -RbxCloud -UpCloud -VMware -Vultr -LXD -NWCS -Akamai" > /tmp/cloud-init.preseed
sudo debconf-set-selections /tmp/cloud-init.preseed

echo "Clean cloud-init state and cache..."
sudo cloud-init clean

echo "Remove cloud-init and dependent packages..."
sudo dpkg-reconfigure -fnoninteractive cloud-init
sudo apt-get purge cloud-init
sudo rm -rf /etc/cloud/ && sudo rm -rf /var/lib/cloud/

sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak

echo "Write file to disable cloud-init network configuration..."
sudo mkdir -p /etc/cloud/cloud.cfg.d/
echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg > /dev/null

echo "Cloud-init has been disabled. Please reboot your system for all changes to take effect."

echo "Press Y to reboot now, or any other key to exit."
read -r -n 1 -s key

if [ "$key" = "Y" ] || [ "$key" = "y" ]; then
  sudo reboot
else
  echo "Exiting without rebooting."
  exit 0
fi
