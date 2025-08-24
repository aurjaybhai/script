#!/usr/bin/env bash
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0.0"
readonly MIN_FEDORA_VERSION=40

# Logging functions
log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Function to display script header
show_header() {
    echo "============================================"
    echo "  Fedora Setup Script v${SCRIPT_VERSION}"
    echo "  Minimum Fedora Version: ${MIN_FEDORA_VERSION}"
    echo "============================================"
    echo
}

# Function to check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        log_info "Please run as a regular user with sudo privileges"
        exit 1
    fi
}

# Function to check Fedora version
check_fedora_version() {
    log_info "Checking system requirements..."
    
    if [[ ! -f "/etc/os-release" ]]; then
        log_error "This doesn't appear to be a Linux system with /etc/os-release"
        exit 1
    fi

    # Source the os-release file to get distribution information
    source /etc/os-release

    # Check if the distribution is Fedora
    if [[ "${ID}" != "fedora" ]]; then
        log_error "You're running ${NAME}, but this script requires Fedora"
        exit 1
    fi

    # Check the version
    if (( VERSION_ID < MIN_FEDORA_VERSION )); then
        log_error "You're running Fedora ${VERSION_ID}, but this script requires Fedora ${MIN_FEDORA_VERSION} or newer."
        log_info "Please upgrade your system or use a different script compatible with older versions."
        exit 1
    fi

    # Verify that DNF is actually available
    if ! command -v dnf &>/dev/null; then
        log_error "DNF package manager not found on Fedora ${VERSION_ID}"
        exit 1
    fi

    # Check for sudo privileges
    if ! sudo -n true 2>/dev/null; then
        log_info "This script requires sudo privileges. Please enter your password."
        sudo -v
    fi

    log_success "Running on Fedora ${VERSION_ID} - all system checks passed!"
}

# Function to update system
update_system() {
    log_info "Updating system packages..."
    
    sudo dnf update -y || {
        log_error "Failed to update system packages"
        exit 1
    }
    
    log_success "System packages updated successfully!"
}

# Function to install essential packages
install_essential_packages() {
    log_info "Installing essential packages..."
    
    local packages=(
        "curl"
        "wget"
        "git"
        "vim"
        "nano"
        "htop"
        "tree"
        "unzip"
        "zip"
        "tar"
        "gcc"
        "gcc-c++"
        "make"
        "cmake"
        "python3"
        "python3-pip"
        "nodejs"
        "npm"
        "java-latest-openjdk"
        "java-latest-openjdk-devel"
        "docker"
        "docker-compose"
        "git-lfs"
        "gnupg2"
        "ca-certificates"
        "lsb-release"
    )
    
    sudo dnf install -y "${packages[@]}" || {
        log_error "Failed to install essential packages"
        exit 1
    }
    
    log_success "Essential packages installed successfully!"
}

# Function to install development tools
install_dev_tools() {
    log_info "Installing development tools and group packages..."
    
    # Install development tools group
    sudo dnf groupinstall -y "Development Tools" "Development Libraries" || {
        log_error "Failed to install development groups"
        exit 1
    }
    
    log_success "Development tools installed successfully!"
}

# Function to install Homebrew
install_homebrew() {
    log_info "Installing Homebrew..."
    
    # Check if Homebrew is already installed
    if command -v brew &>/dev/null; then
        log_info "Homebrew is already installed"
        return 0
    fi
    
    # Install dependencies for Homebrew
    sudo dnf install -y procps-ng curl file git || {
        log_error "Failed to install Homebrew dependencies"
        exit 1
    }
    
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        log_error "Failed to install Homebrew"
        exit 1
    }
    
    # Configure shell for Homebrew
    local shell_rc=""
    if [[ -n "${BASH_VERSION:-}" ]]; then
        shell_rc="$HOME/.bashrc"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bashrc"  # Default to bashrc
    fi
    
    # Add Homebrew to PATH if not already present
    if ! grep -q "/home/linuxbrew/.linuxbrew/bin/brew shellenv" "$shell_rc" 2>/dev/null; then
        {
            echo ""
            echo '# Homebrew configuration'
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
        } >> "${shell_rc}"
    fi
    
    # Load Homebrew in current session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" || {
        log_error "Failed to load Homebrew environment"
        exit 1
    }
    
    log_success "Homebrew installed and configured successfully!"
}

# Function to configure Docker
configure_docker() {
    log_info "Configuring Docker..."
    
    # Start and enable Docker service
    sudo systemctl start docker || {
        log_error "Failed to start Docker service"
        exit 1
    }
    
    sudo systemctl enable docker || {
        log_error "Failed to enable Docker service"
        exit 1
    }
    
    # Add current user to docker group
    sudo usermod -aG docker "$USER" || {
        log_error "Failed to add user to docker group"
        exit 1
    }
    
    log_success "Docker configured successfully!"
    log_info "You may need to log out and back in for Docker group changes to take effect"
}

# Function to install additional repositories
setup_repositories() {
    log_info "Setting up additional repositories..."
    
    # Enable RPM Fusion repositories
    sudo dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" || {
        log_error "Failed to install RPM Fusion repositories"
        exit 1
    }
    
    # Enable Flathub repository
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || {
        log_error "Failed to add Flathub repository"
        exit 1
    }
    
    log_success "Additional repositories configured successfully!"
}

# Function to install multimedia codecs
install_multimedia_codecs() {
    log_info "Installing multimedia codecs..."
    
    sudo dnf install -y \
        gstreamer1-plugins-base \
        gstreamer1-plugins-good \
        gstreamer1-plugins-ugly \
        gstreamer1-plugins-bad-free \
        gstreamer1-plugins-bad-freeworld \
        gstreamer1-libav \
        ffmpeg \
        mozilla-openh264 || {
        log_error "Failed to install multimedia codecs"
        exit 1
    }
    
    log_success "Multimedia codecs installed successfully!"
}

# Function to install popular applications
install_applications() {
    log_info "Installing popular applications..."
    
    # Install via DNF
    local dnf_apps=(
        "firefox"
        "thunderbird"
        "libreoffice"
        "gimp"
        "vlc"
        "obs-studio"
        "code"  # VS Code (if available)
        "telegram-desktop"
        "discord"
        "steam"
    )
    
    for app in "${dnf_apps[@]}"; do
        if sudo dnf install -y "$app" 2>/dev/null; then
            log_success "Installed $app via DNF"
        else
            log_info "Skipped $app (not available via DNF)"
        fi
    done
    
    # Install via Flatpak
    local flatpak_apps=(
        "com.spotify.Client"
        "com.google.Chrome"
        "org.telegram.desktop"
        "com.discordapp.Discord"
        "org.blender.Blender"
        "org.audacityteam.Audacity"
    )
    
    for app in "${flatpak_apps[@]}"; do
        if flatpak install -y flathub "$app" 2>/dev/null; then
            log_success "Installed $app via Flatpak"
        else
            log_info "Skipped $app (not available or already installed)"
        fi
    done
    
    log_success "Applications installation completed!"
}

# Function to configure Git (optional)
configure_git() {
    log_info "Git configuration (optional)..."
    
    if git config --global user.name &>/dev/null && git config --global user.email &>/dev/null; then
        log_info "Git is already configured"
        return 0
    fi
    
    echo -n "Enter your Git username (or press Enter to skip): "
    read -r git_username
    
    if [[ -n "$git_username" ]]; then
        git config --global user.name "$git_username"
        
        echo -n "Enter your Git email: "
        read -r git_email
        
        if [[ -n "$git_email" ]]; then
            git config --global user.email "$git_email"
            log_success "Git configured with username: $git_username and email: $git_email"
        fi
    else
        log_info "Git configuration skipped"
    fi
}

# Function to cleanup
cleanup() {
    log_info "Performing cleanup..."
    
    # Clean DNF cache
    sudo dnf clean all
    
    # Clean Homebrew cache if available
    if command -v brew &>/dev/null; then
        brew cleanup
    fi
    
    log_success "Cleanup completed!"
}

# Function to show completion message
show_completion() {
    echo
    echo "============================================"
    log_success "Fedora setup completed successfully!"
    echo "============================================"
    echo
    log_info "Recommendations:"
    echo "  • Restart your system to ensure all changes take effect"
    echo "  • Log out and back in for Docker group permissions"
    echo "  • Run 'source ~/.bashrc' or 'source ~/.zshrc' to load Homebrew"
    echo "  • Consider installing additional software based on your needs"
    echo
    log_info "Useful commands:"
    echo "  • Update system: sudo dnf update"
    echo "  • Install Flatpak apps: flatpak install flathub <app-id>"
    echo "  • Install Homebrew packages: brew install <package>"
    echo "  • Manage Docker: systemctl status docker"
    echo
}

# Main execution function
main() {
    show_header
    check_not_root
    check_fedora_version
    
    log_info "Starting Fedora system setup..."
    echo
    
    update_system
    install_essential_packages
    install_dev_tools
    setup_repositories
    install_multimedia_codecs
    install_homebrew
    configure_docker
    install_applications
    configure_git
    cleanup
    
    show_completion
}

# Handle script interruption
trap 'log_error "Script interrupted by user"; exit 1' INT TERM

# Run main function
main "$@"