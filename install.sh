#!/usr/bin/env bash

set -euo pipefail # enabling strict error-handling behaviors.

# set -eu     # die on error or undefined

# check if the script is running with arguments(parameters)

if [[ $# -gt 0 ]]; then
    echo "Error : This script should be run with zero arguments.."
    echo "Usage $0 (no arguments allowed)"
    exit 1
fi

# # Check if running as root if not then prompt sudo password

if [[ "$(id -u)" -ne 0 ]]; then
    echo "This script requires root privileges. Re-running with sudo...."
    if ! sudo "$0" "$@"; then # E flag tells sudo to preserve your environment variables (including PATH)
        echo "Error : Failed to obtain root privileges..."
        exit 1
    fi
else
    echo "Running as root (user ID : $(id -u))"
fi

Browsers=("Google Chrome" "Brave" "Zen Browser")

# selected_browsers=gum choose --no-limit "$(Browsers)" ## wrong line
echo "Select Your Browsers :"
selected_browsers=$(gum choose --no-limit "${Browsers[@]}")

echo "You selected : $(echo "$selected_browsers" | tr '\n' ', ' | sed 's/[[:space:]]*,[[:space:]]*$//')" # here $ means at the end of the line

if [[ -n "$selected_browsers" ]]; then
    echo -e "\nInstalling selected browsers....\n"

    # Convert to array for processing
    while IFS= read -r browser; do
        case "$browser" in
        "Google Chrome"
            echo "Downloading Google Chrome" # after echo statement do not put parenthesis()
            # Adding Chrome Commands
            CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"
            CHROME_RPM="google-chrome-stable_current_x86_64.rpm"

            # Download to  your current directory
            echo "Downloading Google Chrome"
            if ! wget "$CHROME_URL" -O "$CHROME_RPM"; then
                echo "Error : Unable to Download...No internet!!"
                exit 1
            fi

            # Install the downloaded RPM
            echo "Installing Google Chrome..."
            if ! dnf install -y "$CHROME_RPM"; then
                echo "Error : Failed to install Google Chrome"
                rm -f "$CHROME_RPM"
                exit 1
            fi
            # CleanUp the downloaded file
            rm -f "$CHROME_RPM"
            echo "✓ Google Chrome installation completed"
            ;;

        esac
    done
fi

# By default, IFS contains:

# Space
# Tab \t
# Newline \n

# # Categories
# 1 browsers(chrome,brave,zen_browser,)
# flatpak
# 2 communication(discord,zoom,telegram)
# 3 text editor(kate,vs code ,sublime text , neovim , vim, intellgia code editor)
# 4 LibreOffice
# Remmina  (rdp protocol)
# 5 multimedia(OBS, VLC, video downlaoder(flatpak))
# Productivity (obsidian,)
# 6 Unity Hub

# shfmt -i 4 -ci -w "script.sh" // run this to format the code

# <<COMMENT
# ed 's/, $//'
# sed is a "stream editor" - it can find and replace text patterns.

# s/ = substitute/replace command

# , $ = comma-space at the end of line ($ means "end of line")

# // = replace with nothing (delete it)

# So sed 's/, $//' means: "find comma-space at the end of line and delete it"
# COMMENT
