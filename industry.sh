#!/usr/bin/env bash

check_requirements() {
    command -v gum >/dev/null || {
        echo "gum required"
        exit 1
    } # command -v new way to check whether program exists or not (which gum is be like 😟😟)
}

get_user_choices() {
    # Always run UI as regular user
    if [[ "$(id -u)" -eq 0 ]]; then
        echo "Getting user input..."
        # If we're root, we need to get the original user
        REAL_USER="${SUDO_USER:-$USER}"
        su - "$REAL_USER" -c "$(declare -f); gum choose --no-limit '${Browsers[*]}'"
    else
        gum choose --no-limit "${Browsers[@]}"
    fi
}

install_packages() {
    # Always elevate for installation
    if [[ "$(id -u)" -ne 0 ]]; then
        sudo "$0" --install "$@"
        return
    fi

    # We're root, do the installation
    # ... installation code here ...
}

main() {
    case "${1:-}" in
    --install)
        shift
        install_packages "$@"
        ;;
    *)
        check_requirements
        selected=$(get_user_choices)
        [[ -n "$selected" ]] && install_packages "$selected"
        ;;
    esac
}

main "$@"
