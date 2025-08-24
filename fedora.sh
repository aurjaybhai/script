#!/usr/bin/env bash

# Professional Fedora Setup Script
# Handles multiple user scenarios and edge cases
# Author: DevOps Team
# Version: 2.0

set -euo pipefail

# Global constants
readonly HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
readonly MIN_FEDORA_VERSION=40
readonly HOMEBREW_SHELLENV_CMD='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

# Logging functions
log_info() {
    echo "ℹ️  [INFO] $*" >&2
}

log_success() {
    echo "✅ [SUCCESS] $*" >&2
}

log_error() {
    echo "❌ [ERROR] $*" >&2
}

log_warning() {
    echo "⚠️  [WARNING] $*" >&2
}

# Check if Homebrew shellenv is already in bashrc
is_homebrew_in_bashrc() {
    if [[ -f "$HOME/.bashrc" ]] && grep -q "linuxbrew" "$HOME/.bashrc"; then
        return 0
    else
        return 1
    fi
}

# Ensure Homebrew is available in current session
ensure_homebrew_available() {
    # Try multiple methods to make brew available
    if command -v brew &>/dev/null; then
        log_info "Homebrew is already available in current session"
        return 0
    fi

    # Try to load it manually
    if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        log_info "Loading Homebrew into current session..."
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        return 0
    fi

    # Check other common locations
    local common_paths=(
        "/opt/homebrew/bin/brew"
        "/usr/local/bin/brew"
        "$HOME/.linuxbrew/bin/brew"
    )

    for brew_path in "${common_paths[@]}"; do
        if [[ -x "$brew_path" ]]; then
            log_info "Found Homebrew at: $brew_path"
            eval "$($brew_path shellenv)"
            return 0
        fi
    done

    return 1
}

check_fedora_version() {
    log_info "Checking Fedora version..."
    
    if [[ ! -f "/etc/os-release" ]]; then
        log_error "This doesn't appear to be a Linux system with /etc/os-release"
        exit 1
    fi

    # Source the os-release file to get distribution information
    # shellcheck source=/dev/null
    source /etc/os-release

    # Check if the distribution is fedora
    if [[ "$ID" != "fedora" ]]; then
        log_error "You're running $NAME, but this script requires Fedora"
        exit 1
    fi

    # Check the version
    if ((VERSION_ID < MIN_FEDORA_VERSION)); then
        log_error "You're running Fedora $VERSION_ID, but this script requires Fedora $MIN_FEDORA_VERSION or newer"
        log_error "Please upgrade your system or use a different script compatible with YUM"
        exit 1
    fi

    # Verify that DNF is actually available
    if ! command -v dnf &>/dev/null; then
        log_error "DNF package manager not found on Fedora $VERSION_ID"
        exit 1
    fi

    log_success "Fedora $VERSION_ID detected and compatible"
}

install_homebrew() {
    log_info "Installing Homebrew..."
    
    # Check if curl is available
    if ! command -v curl &>/dev/null; then
        log_error "curl is required but not installed. Installing curl first..."
        sudo dnf install -y curl || {
            log_error "Failed to install curl"
            return 1
        }
    fi

    # Install development tools first (Homebrew dependency)
    log_info "Installing development tools (required for Homebrew)..."
    if ! sudo dnf group install -y "Development Tools"; then
        log_warning "Failed to install Development Tools, but continuing..."
    fi

    # Download and execute Homebrew installer
    if /bin/bash -c "$(curl -fsSL "$HOMEBREW_INSTALL_URL")"; then
        log_success "Homebrew installation completed!"
        
        # Configure Homebrew in .bashrc (only if not already there)
        if ! is_homebrew_in_bashrc; then
            log_info "Adding Homebrew to your .bashrc..."
            {
                echo ""
                echo "# Homebrew configuration (added by setup script)"
                echo "$HOMEBREW_SHELLENV_CMD"
            } >> "$HOME/.bashrc"
            log_success "Homebrew added to .bashrc"
        else
            log_info "Homebrew configuration already exists in .bashrc"
        fi
        
        # Load Homebrew in current session
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        
        return 0
    else
        log_error "Homebrew installation failed!"
        log_error "Please check your internet connection and try again"
        return 1
    fi
}

setup_homebrew() {
    # Professional approach: Handle all possible states
    
    # State 1: Check if brew command is available
    if command -v brew &>/dev/null; then
        log_success "Homebrew is already installed and available"
        
        # Verify it's working
        if brew --version &>/dev/null; then
            log_success "Homebrew is working correctly"
            return 0
        else
            log_warning "Homebrew command found but not working properly"
            log_info "Attempting to fix Homebrew setup..."
        fi
    fi
    
    # State 2: Homebrew might be installed but not in PATH
    if ensure_homebrew_available; then
        log_success "Homebrew is now available"
        
        # Make sure it's in bashrc for future sessions
        if ! is_homebrew_in_bashrc; then
            log_info "Adding Homebrew to .bashrc for future sessions..."
            {
                echo ""
                echo "# Homebrew configuration (added by setup script)"
                echo "$HOMEBREW_SHELLENV_CMD"
            } >> "$HOME/.bashrc"
        fi
        return 0
    fi
    
    # State 3: Homebrew is not installed at all
    log_info "Homebrew not found on this system"
    
    # Professional scripts don't assume - they ask
    echo "Would you like to install Homebrew? It's required for this setup. (y/n)"
    read -r response
    
    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            if install_homebrew; then
                log_success "Homebrew setup completed successfully!"
                return 0
            else
                log_error "Failed to install Homebrew"
                return 1
            fi
            ;;
        *)
            log_error "Homebrew is required for this script to continue"
            log_info "Please install Homebrew manually and run this script again"
            exit 1
            ;;
    esac
}

install_gum() {
    log_info "Installing gum via Homebrew..."
    
    # Make sure Homebrew is available
    if ! command -v brew &>/dev/null; then
        log_error "Homebrew not available. Cannot install gum"
        return 1
    fi
    
    # Install gum
    if brew install gum; then
        log_success "Gum installed successfully!"
        return 0
    else
        log_error "Failed to install gum"
        return 1
    fi
}

setup_gum() {
    if command -v gum &>/dev/null; then
        log_success "Gum is already installed"
        
        # Verify it's working
        if gum --version &>/dev/null; then
            return 0
        else
            log_warning "Gum command found but not working properly"
        fi
    fi
    
    log_info "Gum not found or not working. Installing..."
    install_gum
}

check_requirements() {
    log_info "Checking and setting up requirements..."
    
    # Setup Homebrew (handles all edge cases)
    if ! setup_homebrew; then
        log_error "Cannot proceed without Homebrew"
        exit 1
    fi
    
    # Setup gum
    if ! setup_gum; then
        log_error "Cannot proceed without gum"
        exit 1
    fi
    
    log_success "All requirements are satisfied!"
}

get_user_choices() {
    local browsers=("Google Chrome" "Brave" "Zen Browser" "LibreWolf")

    log_info "Please select your preferred browsers:"
    
    # Check if gum is actually working before using it
    if ! gum --version &>/dev/null; then
        log_error "Gum is not working properly"
        exit 1
    fi
    
    local selected_browsers
    selected_browsers=$(gum choose --no-limit "${browsers[@]}") || {
        log_error "Browser selection was cancelled or failed"
        exit 1
    }
    
    if [[ -n "$selected_browsers" ]]; then
        log_success "You selected: $selected_browsers"
    else
        log_warning "No browsers selected"
    fi
}

# Cleanup function for graceful exits
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Script failed with exit code $exit_code"
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Main execution
main() {
    log_info "🚀 Starting Professional Fedora Setup Script..."
    log_info "Script will handle existing installations gracefully"
    
    # Run checks in order
    check_fedora_version
    check_requirements
    get_user_choices
    
    log_success "🎉 Setup completed successfully!"
    log_info "Please restart your terminal or run 'source ~/.bashrc' to ensure all changes take effect"
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi