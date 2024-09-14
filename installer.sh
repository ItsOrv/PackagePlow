#!/bin/bash

# Check for root privileges
if [ "$(whoami)" != 'root' ]; then
    echo "You must be root to run this script!"
    exit 1
fi

# Check for Alpine Linux
if [ -f /etc/alpine-release ]; then
    echo "This script does not support Alpine distros"
    exit 1
fi

# Read package names from file
package_names=""
while IFS= read -r line; do
    package_names="${package_names} ${line}"
done < package.txt

# Determine package manager based on distribution
declare -A pManager
pManager[/etc/redhat-release]=yum
pManager[/etc/arch-release]=pacman
pManager[/etc/gentoo-release]=emerge
pManager[/etc/SuSE-release]=zypper
pManager[/etc/debian_version]=apt-get

# Install packages based on distribution
for f in "${!pManager[@]}"; do
    if [ -f "$f" ]; then
        case ${pManager[$f]} in
            yum)
                sudo yum install -y $package_names
                ;;
            pacman)
                sudo pacman -S --noconfirm $package_names
                ;;
            emerge)
                sudo emerge -av $package_names
                ;;
            zypper)
                sudo zypper install -y $package_names
                ;;
            apt-get)
                sudo apt-get update
                sudo apt-get install -y $package_names
                ;;
            *)
                echo "Package manager not supported"
                ;;
        esac
        exit 0
    fi
done

echo "Unsupported Linux distribution."
