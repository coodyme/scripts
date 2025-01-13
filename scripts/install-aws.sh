#!/bin/bash

# This script installs the AWS CLI v2 on Ubuntu and configures the AWS environment.
# ------------------------------------------------------------------------------
# How to use:
# 1. Save this script to a file (e.g., install-aws.sh)
# 2. Make the script executable with the command: chmod +x install-aws.sh
# 3. Run the script with root privileges: sudo ./install-aws.sh
# ------------------------------------------------------------------------------

# Define the shell profile
SHELL_PROFILE="$HOME/.zshrc"

# Function to install AWS CLI
install() {
    echo "Updating package list and installing prerequisites..."
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install -y unzip curl

    echo "Downloading AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

    echo "Unzipping AWS CLI installer..."
    unzip -o awscliv2.zip

    echo "Installing AWS CLI..."
    sudo ./aws/install

    echo "Cleaning up temporary files..."
    rm -rf awscliv2.zip aws

    echo "Verifying AWS CLI installation..."
    aws --version
    if [ $? -eq 0 ]; then
        echo "AWS CLI installed successfully!"
    else
        echo "Error: AWS CLI installation failed."
        exit 1
    fi
}

configure_profile() {
    echo "Configuring AWS environment variables..."
    read -p "Enter your AWS Access Key ID: " AWS_ACCESS_KEY_ID
    read -p "Enter your AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
    read -p "Enter your Default AWS Region (e.g., us-east-1): " AWS_DEFAULT_REGION

    echo "Exporting AWS environment variables to shell profile..."
    echo "export AWS_ACCESS_KEY_ID=\"$AWS_ACCESS_KEY_ID\"" >> $SHELL_PROFILE
    echo "export AWS_SECRET_ACCESS_KEY=\"$AWS_SECRET_ACCESS_KEY\"" >> $SHELL_PROFILE
    echo "export AWS_DEFAULT_REGION=\"$AWS_DEFAULT_REGION\"" >> $SHELL_PROFILE

    echo "Applying changes to shell environment..."
    source $SHELL_PROFILE

    echo "Testing AWS CLI with provided credentials..."
    aws sts get-caller-identity
    if [ $? -eq 0 ]; then
        echo "AWS environment configured successfully!"
    else
        echo "Error: AWS environment configuration failed. Check your credentials and try again."
    fi
}

add_profile() {
    echo "Adding a new AWS CLI profile..."
    read -p "Enter the profile name (e.g., dev, prod): " PROFILE_NAME
    read -p "Enter your AWS Access Key ID: " AWS_ACCESS_KEY_ID
    read -p "Enter your AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
    read -p "Enter your Default AWS Region (e.g., us-east-1): " AWS_DEFAULT_REGION

    # Update AWS credentials file
    AWS_CREDENTIALS_FILE="$HOME/.aws/credentials"
    echo "[$PROFILE_NAME]" >> $AWS_CREDENTIALS_FILE
    echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> $AWS_CREDENTIALS_FILE
    echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> $AWS_CREDENTIALS_FILE

    # Update AWS config file
    AWS_CONFIG_FILE="$HOME/.aws/config"
    echo "[profile $PROFILE_NAME]" >> $AWS_CONFIG_FILE
    echo "region = $AWS_DEFAULT_REGION" >> $AWS_CONFIG_FILE

    echo "New profile '$PROFILE_NAME' added successfully!"
    echo "To use it, run AWS CLI commands with: --profile $PROFILE_NAME"
}

# Display options to the user
echo "Select an option:"
echo "1. Just Install AWS CLI"
echo "2. Install and Configure AWS Profile"
echo "3. Reconfigure AWS Profile"
echo "4. Add a new AWS Profile"

read -p "Enter your choice (1/2/3/4): " CHOICE

case $CHOICE in
    1)
        echo "Installing AWS CLI..."
        install
        ;;
    2)
        echo "Installing and configuring AWS Profile..."
        install
        configure_profile
        ;;
    3)
        echo "Reconfiguring AWS Profile..."
        configure_profile
        ;;
    4)
        echo "Adding a new AWS CLI Profile..."
        add_profile
        echo "Remember to use the aws --profile <my_profile> flag with AWS CLI commands to specify the profile."
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac