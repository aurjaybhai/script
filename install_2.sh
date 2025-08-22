#!/usr/bin/env bash

set -euo pipefail

Browsers=("Google Chrome" "Brave" "Zen Browser")

# Funtion 1 : Check if we have required tools
# homebrew installed
# gum installed
# the system should be fedora linux only
check_requirements() {
    if ! command -v brew &> /dev/null; then
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
    if ! command -v gum &> /dev/null; then
         brew install gum
    else
        echo "Please Check Your Internet Connection..."
}

get_user_choices(){

    Browsers=("Google Chrome" "Brave" "Zen Browser" "LibreWolf")

    echo "Select Your Browsers : "
    selected_browser=$(gum choose --no-limit "{$Browsers[@]}")

    echo "${selected_browser}"



}
