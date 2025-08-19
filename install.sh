#!/usr/bin/env bash

set -euo pipefail # enabling strict error-handling behaviors.

# set -eu     # die on error or undefined

# check if the script is running with arguments(parameters)

# if [[ $# -gt 0 ]]; then
#     echo "Error : This script should be run with zero arguments.."
#     echo "Usage $0 (no arguments allowed)"
#     exit 1
# fi

# # Check if running as root if not then prompt sudo password

# if [[ "$(id -u)" -ne 0 ]]; then
#     echo "This script requires root privileges. Re-running with sudo...."
#     if ! sudo "$0" "$@"; then
#         echo "Error : Failed to obtain root privileges..."
#         exit 1
#     fi
# else
#     echo "Running as root (user ID : $(id -u))"
# fi

Browsers=("Google-Chrome" "Brave" "Zen Browser")

selected_browsers=$(gum choose --no-limit \ --header "Select browsers:" \ --selected-prefix "✓ " --unselected_prefix " " \ "${Browsers[@]}")

echo -ne "You selected : $selected_browsers"
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
