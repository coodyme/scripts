#!/bin/bash

# This script installs Docker
# ------------------------------------------------------------------------------
# How to use:
# 1. Save this script to a file (e.g., install-docker.sh)
# 2. Make the script executable with the command: chmod +x install-docker.sh
# 3. Run the script with root privileges: sudo ./install-docker.sh
# ------------------------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "Removing old versions..."
sudo apt-get remove docker docker-engine docker.io containerd runc

echo "Installing and updating required packages..."
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg

echo "Adding Docker's GPG key and Repository..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

echo "Installing Docker..."
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Enabling and starting Docker service..."
systemctl enable docker
systemctl start docker

echo "Verifying Docker installation..."
docker --version

echo "Adding current user to the Docker group..."
newgrp docker
sudo groupadd docker
sudo usermod -aG docker $USER

echo "Docker installation completed successfully!"
echo "You may need to log out and log back in for non-root Docker access."
