#!/usr/bin/env bash

# Function: ask_question
# Description: Prompts the user for input and returns the answer
# Arguments:
#   $1: The question to ask the user
# Returns: The user's input
ask_question() {
    read -r -p "$(tput setaf 4)?$(tput sgr0) $1 " answer
    echo "${answer}"
}

# Function: yes_no
# Description: Prompts the user for a yes/no response and returns 0 for "yes" and 1 for anything else.
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
    read -p "$(tput setaf 4)?$(tput sgr0) $1 (Y/n):  " response
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

# Function: gregorian_to_persian
# Description: Converts Gregorian date to Persian date
# Arguments:
#   None
# Returns: The Persian date in the format 'YYYY-MM-DD'
gregorian_to_persian() {
    echo "$(echo $(date +'%Y-%m-%d') | source "${workdir}/sources/_pcal.sh" -D "_")"
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

# Function: convert_to_absolute_path
# Description: Converts a relative path to an absolute path
# Arguments:
#   $1: The relative path to convert
# Returns:
#   The absolute path
convert_to_absolute_path() {
    local relative_path="${1}"
    local absolute_path

    # Check if the path exists
    if [ -e "${relative_path}" ]; then
        absolute_path=$(realpath "${relative_path}")
        echo "${absolute_path}"
    else
        message_error "The path '${relative_path}' does not exist."
        exit 1
    fi
}

# Function: docker_service_is_running
# Description: This function checks if a Docker service is running by searching for its name in the list of running containers.
# Arguments:
#   $1: The name of the Docker service to check for
# Returns:
#   0 if the service is running, 1 if it is not running
docker_service_is_running() {
    local service_name="$1" # Assign the input parameter (service name) to a local variable

    # Check if the specified service is running by searching for its name in the list of running containers
    if docker compose ps --format '{{.Names}}' | grep "${service_name}\$" >/dev/null; then
        return 0 # Return 0 to indicate that the service is running
    else
        return 1 # Return 1 to indicate that the service is not running
    fi
}
