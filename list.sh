#!/bin/bash

echo " __        __   _                         "
echo " \ \      / /__| | ___ ___  _ __ ___   ___"
echo "  \ \ /\ / / _ \ |/ __/ _ \| '_ \` _ \ / _ \ "
echo "   \ V  V /  __/ | (_| (_) | | | | | |  __/ | "
echo "    \_/\_/ \___|_|\___\___/|_| |_| |_|\___| "
echo ""

# Get list of all scripts in the src directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$(dirname "$SCRIPT_DIR")/src"

if [ ! -d "$SRC_DIR" ]; then
    echo "Error: src directory not found at $SRC_DIR."
    exit 1
fi

# Get all script files in the src directory
scripts=()
i=1
while IFS= read -r script_path; do
    script_name=$(basename "$script_path")
    scripts+=("$script_name")
    echo "  $i) $script_name"
    ((i++))
done < <(find "$SRC_DIR" -type f -name "*.sh" | sort)

if [ ${#scripts[@]} -eq 0 ]; then
    echo "No scripts found in $SRC_DIR."
    exit 1
fi

# Display menu
echo "Available scripts:"
echo "-----------------"

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
    bash "$SRC_DIR/$selected_script"
else
    echo "Invalid selection. Please run the command again and select a valid option."
    exit 1
fi