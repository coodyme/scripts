#!/bin/bash

echo " __        __   _                         "
echo " \ \      / /__| | ___ ___  _ __ ___   ___"
echo "  \ \ /\ / / _ \ |/ __/ _ \| '_ \` _ \ / _ \ "
echo "   \ V  V /  __/ | (_| (_) | | | | | |  __/ | "
echo "    \_/\_/ \___|_|\___\___/|_| |_| |_|\___| "
echo ""

# Get list of all scripts in the src directory
BASE_URL="https://scripts.coody.me/src"
SCRIPTS_LIST=$(curl -s $BASE_URL/index.txt)

if [ -z "$SCRIPTS_LIST" ]; then
    echo "Error: Could not fetch the scripts list."
    exit 1
fi

# Display menu
echo "Available scripts:"
echo "-----------------"

# Parse scripts and show them as a numbered list
IFS=$'\n' # Set Internal Field Separator to newline
scripts=()
i=1
for script in $SCRIPTS_LIST; do
    scripts+=("$script")
    echo "  $i) $script"
    ((i++))
done

# Prompt for selection
echo ""
echo "Enter the number of the script you want to run (or 'q' to quit):"
read -r choice

# Handle selection
if [[ "$choice" == "q" ]]; then
    echo "Exiting..."
    exit 0
fi

if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#scripts[@]}" ]; then
    selected_script="${scripts[$choice-1]}"
    echo "Running $selected_script..."
    echo "=================================="
    
    # Execute the selected script
    curl -s "$BASE_URL/$selected_script" | bash
else
    echo "Invalid selection. Please run the command again and select a valid option."
    exit 1
fi