#!/usr/bin/env bash

# Function: yes_no
# Description: Prompts the user for a yes/no response
# Arguments:
#   $1: The message to display to the user.
# Returns:
#   0 if the user responds with "yes", 1 for any other response.
# Usage: if yes_no "Do you want to proceed?"; then
#            # Proceed with the operation
#        else
#            # Cancel the operation
#        fi
yes_no() {
    local response=""
    read -p "$(tput setaf 4)?$(tput sgr0) $1 (Y/n)  " response
    response=${response:-"y"}

    case "$response" in
    [yY])
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

# Function: list_backups
# Description: Lists backup files based on a given pattern
# Arguments:
#   $1: pattern - the pattern to search for in backup filenames
#   $2: path (optional) - the directory path to search for backup files (default: $BACKUP_DIR)
# Returns: None
list_backups() {
    local path="${2:-$BACKUP_DIR}"

    # Find files matching the pattern in the specified path
    find "${path}" -type f \( -name "$1" \) -exec ls -lht --color=never {} + |
        awk '{ "stat -c %y " $9 | getline file_date; file=substr($9, 10); sub(/\.[0-9]+/, "", file_date); \
        printf "\033[1;31m  File:\033[0m %-55s \033[1;35mDate:\033[0m %-25s \033[1;32m\tSize:\033[0m %-10s \033[1;34mOwner:\033[0m %s\n", file, file_date, $5, $3}'
}

# Function: countdown
# Description: Performs a simple countdown
# Arguments:
#   $1: The number of seconds for the countdown
# Returns: None
countdown() {
    # Description of the function
    declare desc="A simple countdown."

    # Input parameter: number of seconds for the countdown
    local seconds="${1}"

    # Calculate the end time of the countdown
    local d=$(($(date +%s) + $seconds))

    # Loop until the end time is reached
    while [ "$d" -ge $(date +%s) ]; do
        # Print the remaining time in HH:MM:SS format
        echo -ne "$(date -u --date @$(($d - $(date +%s))) +%H:%M:%S)\r"

        # Wait for a short duration
        sleep 0.1
    done
}
