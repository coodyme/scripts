#!/bin/bash

set -e

echo "Installing Yarn 1.22.22 on Ubuntu..."

echo "Updating package list and installing required dependencies..."
sudo apt update && sudo apt install -y curl gnupg

echo "Adding Yarn APT repository..."
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt update

echo "Installing Yarn 1.22.22..."
sudo apt install -y yarn=1.22.22-1

echo "Checking Yarn version..."
yarn --version

echo "🎉 Installation complete! Yarn 1.22.22 is now installed."