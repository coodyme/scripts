#!/bin/bash

# Make a backup of the original sshd_config file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Use sed to replace '#PermitRootLogin prohibit-password' with 'PermitRootLogin yes'
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Restart the SSH service to apply the changes
systemctl restart sshd

echo "Changes applied and SSH service restarted."
