#!/bin/bash

# List all .sh files in the repository
echo "Available scripts:"
scripts=($(find ./scripts -type f -name "*.sh" | sort))
for i in "${!scripts[@]}"; do
    echo "$((i+1)) - ${scripts[$i]#./scripts/}"
done

# Add an option to exit
echo "X. Exit"

# Prompt the user to select a script
echo
read -p "Enter the number of the script you want to run (or X to exit): " selection

# Handle selection
if [[ "$selection" =~ ^[Xx]$ ]]; then
    echo "Exiting..."
    exit 0
elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -gt 0 && $selection -le ${#scripts[@]} ]]; then
    selected_script="${scripts[$((selection-1))]}"
    echo "Running script: $selected_script"
    chmod +x "$selected_script" # Ensure the script is executable
    "$selected_script"          # Run the script
else
    echo "Invalid selection."
fi