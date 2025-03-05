#!/bin/bash

# This script generates a random password and copies it to the clipboard.
# ------------------------------------------------------------------------------
# How to use:
# 1. Create a new file: sudo nano gen-pwd.sh
# 2. Copy the contents of this script into the file and save it.
# 3. Make the script executable with the command: sudo chmod +x gen-pwd.sh
# 4. Run the script with root privileges: sudo ./gen-pwd.sh
# ------------------------------------------------------------------------------

generate_password() {
    local length=$1
    local special_chars=$2

    if [ "$special_chars" == "yes" ]; then
        openssl rand -base64 $((length * 3 / 4)) | tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}<>?'
    else
        openssl rand -base64 $((length * 3 / 4)) | tr -dc 'A-Za-z0-9'
    fi
}

echo "Select the password length:"
echo "1) 16 characters"
echo "2) 32 characters"
echo "3) 64 characters"
read -p "Enter your choice (1/2/3): " choice

case $choice in
    1) length=16 ;;
    2) length=32 ;;
    3) length=64 ;;
    *) echo "Invalid choice"; exit 1 ;;
esac

read -p "Include special characters? (yes/no): " include_special

password=$(generate_password $length $include_special)

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -n "$password" | pbcopy
else
    sudo apt-get install xclip -y
    echo -n "$password" | xclip -selection clipboard
fi

echo "Generated password: $password and copied to clipboard."