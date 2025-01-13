#!/bin/bash

# This script changes the IP address, subnet mask, gateway, and DNS server of a network interface using Netplan.
# ------------------------------------------------------------------------------
# How to use:
# 1. Save this script to a file (e.g., change-ip.sh)
# 2. Make the script executable with the command: chmod +x change-ip.sh
# 3. Run the script with root privileges: sudo ./change-ip.sh <IP_ADDRESS> <SUBNET_MASK> <GATEWAY> <DNS> <INTERFACE>
# sudo ./change-ip.sh 192.168.1.100 255.255.255.0 192.168.1.1 1.1.1.1 ens3
# ------------------------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check for the required parameters
if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <IP_ADDRESS> <SUBNET_MASK> <GATEWAY> <DNS> [INTERFACE]"
  echo "Example: $0 192.168.1.100 255.255.255.0 192.168.1.1 1.1.1.1 ens33"
  exit 1
fi

# Parameters
IP_ADDRESS=$1
SUBNET_MASK=$2
GATEWAY=$3
DNS=$4
INTERFACE=${5:-ens33}  # Default to 'ens33' if no interface is provided

# Convert subnet mask to CIDR (e.g., 255.255.255.0 -> 24)
mask_to_cidr() {
  local mask=$1
  local cidr=0
  IFS=. read -r octet1 octet2 octet3 octet4 <<<"$mask"
  for octet in $octet1 $octet2 $octet3 $octet4; do
    case $octet in
      255) ((cidr+=8)) ;;
      254) ((cidr+=7)) ;;
      252) ((cidr+=6)) ;;
      248) ((cidr+=5)) ;;
      240) ((cidr+=4)) ;;
      224) ((cidr+=3)) ;;
      192) ((cidr+=2)) ;;
      128) ((cidr+=1)) ;;
      0) ;;
      *) echo "Invalid subnet mask: $mask"; exit 1 ;;
    esac
  done
  echo "$cidr"
}

CIDR=$(mask_to_cidr "$SUBNET_MASK")

NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"
if [ -f $NETPLAN_FILE ]; then
  echo "Netplan configuration file found: $NETPLAN_FILE"
  cp $NETPLAN_FILE ${NETPLAN_FILE}.bak
fi

# Write the new Netplan configuration
cat <<EOF >$NETPLAN_FILE
network:
  version: 2
  renderer: networkd
  ethernets:
    ${INTERFACE}:
      addresses:
        - ${IP_ADDRESS}/${CIDR}
      routes:
        - to: default
          via: ${GATEWAY}
      nameservers:
        addresses:
          - ${DNS}
EOF

echo "Applying new IP configuration for interface ${INTERFACE}..."
netplan apply

# Check if the configuration was applied successfully
if [ $? -eq 0 ]; then
  echo "IP address successfully changed to ${IP_ADDRESS} with subnet ${SUBNET_MASK}, gateway ${GATEWAY}, and DNS ${DNS} on interface ${INTERFACE}."
else
  echo "Failed to apply the new IP configuration. Restoring the backup."
  cp ${NETPLAN_FILE}.bak $NETPLAN_FILE
  netplan apply
fi

echo "Press Y to reboot now, or any other key to exit."
read -r -n 1 -s key

if [ "$key" = "Y" ] || [ "$key" = "y" ]; then
  sudo reboot
else
  echo "Exiting without rebooting."
  exit 0
fi
