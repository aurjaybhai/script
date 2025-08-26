#!/bin/bash

set -euo pipefail

# First Checked whether the user is using linux operating system

if [[ ! -f /etc/os-release ]]; then
    echo "You are not using linux operating system"
    exit 1
else
    echo "congratulation you have the file!!"
fi

# Check whether it's ubuntu or fedora
# shellcheck source=/dev/null
source /etc/os-release

# NAME="Ubuntu"
# VERSION_ID="24.04"
# ID=ubuntu

ubuntu() {
    if [[ $ID == "ubuntu" ]]; then
        echo "Using Ubuntu $VERSION_ID"
    fi
}
fedora() {
    if [[ $ID == "fedora" ]]; then
        echo "Using Fedora $VERSION_ID"
    fi
}

if [[ $ID == "ubuntu" ]]; then
    echo "You are using $NAME $VERSION_ID"
elif [[ $ID == "fedora" ]]; then
    echo "You are using $NAME $VERSION_ID"
else
    echo "This script is designed for ubuntu/debian and fedora system only"
    exit 1
fi

if [[ $ID == "ubuntu" ]]; then
    sudo apt -y update
elif [[ $ID == "fedora" ]]; then
    sudo dnf -y update
else
    echo "error"
    exit 1
fi

install_package() {

    local package_name="$1"

    echo "Installing $package_name on $ID..."

    case "$ID" in
        ubuntu | debian)
            sudo apt install -y "$package_name"
            ;;
        fedora | rhel | centos)
            sudo dnf install -y "$package_name"
            ;;

        *)
            echo "Unsupported distribution for this script : $ID"
            return 1
            ;;
    esac

    echo "✅ $package_name installed successfully"

}

if [[ $ID == "ubuntu" ]]; then
    sudo apt update
elif [[ $ID == "fedora" ]]; then
    sudo dnf update
else
    echo "You are using '$ID LINUX DISTRO' which is not supported for this script  !!!!!"
fi

# Installing Basic System Packages

if [[ $ID == "ubuntu" ]]; then
    echo "Installing Ubuntu Packages....."
    packages=("git" "curl" "wget" "build-essential" "htop" "bpytop" "clang" "cargo" "libc6-i386" "libc6-x32" "libu2f-udev" "samba-common-bin" "unrar" "linux-headers-$(uname -r)" "linux-headers-generic" "git" "unzip" "ntfs-3g" "p7zip" "bzip2" "tar" "p7zip-full" "openjdk-21-jdk" "python3-pip")

    for pkg in "${packages[@]}"; do #due to double quoted the word will not split , so the  loop will run ones only
        install_package "$pkg"
    done

elif [[ $ID == "fedora" ]]; then
    echo "Installing fedora packages...."
    fedora_packages=("git" "curl" "wget")

    for pkg in "${fedora_packages[@]}"; do
        install_package "$pkg"
    done

else
    echo "No Package list defined for $ID"
fi

#FEDORA
#  android-tools
# java-21-openjdk.x86_64

# htop clang cargo curl wget git unzip ntfs-3g p7zip-full
