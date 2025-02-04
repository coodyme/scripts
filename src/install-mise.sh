
#!/bin/bash

# Exit if any command fails
set -e

echo "Updating package list and installing dependencies..."
sudo apt update -y && sudo apt install -y gpg sudo wget curl
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
sudo apt update

echo "Installing mise..."
sudo apt install -y mise                                           


echo "Checking mise version..."
mise --version

echo 'eval "$(mise activate bash)"' >> ~/.bashrc

echo "Installing Node.js 18.18.2"
mise use --global node@18.18.2

echo "Installation complete! You can now use 'mise'."




