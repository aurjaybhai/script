#!/usr/bin/env bash

set -euo pipefail

Browsers=("Google Chrome" "Brave" "Zen Browser")

# Funtion 1 : Check if we have required tools
# homebrew installed
# gum installed
# the system should be fedora linux only

check_fedora_version() {

    if [[ ! -f "/etc/os-release" ]]; then # -f checks if a file exists and is a regular file
        echo "Error ! This doesn't appear to be Linux system with /etc/os-release" >&2
        exit 1
    fi

    # Source the os-release file to get distribution information
    source /etc/os-release

    # Check if the distribution is fedora
    if [[ "$ID" != "fedora" ]]; then
        echo "You're running $NAME ,but this script requires Fedora" >&2
        exit 1
    fi

    # Check the version
    if ((VERSION_ID < 40)); then
        echo "You're running Fedora $VERSION_ID, But this script requires Fedora 40 or newer." >&2
        echo "Please upgrade your system or use a different script compatible with YUM." >&2
        exit 1
    fi

    # Verify that DNF is actually available
    if ! command -v dnf &>/dev/null; then
        echo "DNF Package manager not found on Fedora $VERSION_ID " >&2
        exit 1
    fi

}

check_requirements() {
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found . Would you like to install it(y/n)"
        read -r response
        if [[ $response =~ ^[Yy]$ ]]; then # This line uses regex(regular experession) pattern "=~  ==> this is the regex match operator"
            # "^" Means start of the string #"end of the string($)"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo "Please install Homebrew manually first"
            exit 1
        fi
    fi

    # Check if the gum is installed or not
    if ! command -v gum &>/dev/null; then
        brew install gum
    else
        echo "Please Check Your Internet Connection..."
    fi

}

get_user_choices() {

    Browsers=("Google Chrome" "Brave" "Zen Browser" "LibreWolf")

    echo "Select Your Browsers : "
    selected_browser=$(gum choose --no-limit "${Browsers[@]}") # use the dollar sign outside the curly braces

    echo "${selected_browser}"
}

echo "✓ Running on Fedora $VERSION_ID with DNF package manager."

