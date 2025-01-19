#!/bin/bash

# This script installs the Terraform CLI.
# ------------------------------------------------------------------------------
# How to use:
# 1. Save this script to a file (e.g., install-tf.sh)
# 2. Make the script executable with the command: chmod +x install-tf.sh
# 3. Run the script with root privileges: sudo ./install-tf.sh
# ------------------------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "Updating package list..."
sudo apt update -y

echo "Installing prerequisites..."
sudo apt install -y gnupg software-properties-common curl

echo "Adding HashiCorp GPG key..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "Adding HashiCorp repository to sources list..."
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "Updating package list again..."
sudo apt update -y

echo "Installing Terraform..."
sudo apt install terraform -y

echo "Verifying Terraform installation..."
terraform -v

if [ $? -eq 0 ]; then
    echo "Terraform installation completed successfully!"
else
    echo "Error: Terraform installation failed."
    exit 1
fi