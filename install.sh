#!/bin/bash

# Cron Manager - Installation Script
# Auto-detects distro and installs dependencies

# Function to detect package manager
detect_package_manager() {
    if command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# Check for the distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    distro=$ID_LIKE
    # Some distros like Fedora doesn't have "ID_LIKE" in their /etc/os-release file
    if [ -z "$distro" ]; then
        distro=$ID
    fi
fi

echo "Cron Manager - Dependency Installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

case $distro in
    # Arch Linux and derivatives (Manjaro, EndeavourOS, CachyOS, ArcoLinux, etc.)
    "arch")
        echo "→ Detected Arch Linux or derivative"
        pacman -Qi zenity cronie &> /dev/null || sudo pacman -S --needed zenity cronie
        sudo systemctl enable --now cronie
        ;;

    # Debian and derivatives (Ubuntu, Linux Mint, Pop!_OS, Elementary, etc.)
    "debian")
        echo "→ Detected Debian or derivative"
        dpkg -s zenity cron &> /dev/null || sudo apt install -y zenity cron
        sudo systemctl enable --now cron
        ;;

    # Entry for Linux Mint 21.3 Edge and other multi-base distros
    "ubuntu debian")
        echo "→ Detected Ubuntu/Debian derivative"
        dpkg -s zenity cron &> /dev/null || sudo apt install -y zenity cron
        sudo systemctl enable --now cron
        ;;

    # Fedora
    "fedora")
        echo "→ Detected Fedora"
        rpm -q zenity cronie &> /dev/null || sudo dnf install -y zenity cronie
        sudo systemctl enable --now crond
        ;;

    # OpenSUSE
    "opensuse-tumbleweed"|"opensuse")
        echo "→ Detected OpenSUSE"
        rpm -q zenity cronie &> /dev/null || sudo zypper install -y zenity cronie
        sudo systemctl enable --now cron
        ;;

    # Unknown distro - attempt package manager detection
    *)
        echo "→ Unknown distro, attempting package manager detection..."
        package_manager=$(detect_package_manager)

        case $package_manager in
            "pacman")
                echo "→ Detected pacman package manager"
                pacman -Qi zenity cronie &> /dev/null || sudo pacman -S --needed zenity cronie
                sudo systemctl enable --now cronie
                ;;
            "apt")
                echo "→ Detected apt package manager"
                dpkg -s zenity cron &> /dev/null || sudo apt install -y zenity cron
                sudo systemctl enable --now cron
                ;;
            "dnf")
                echo "→ Detected dnf package manager"
                rpm -q zenity cronie &> /dev/null || sudo dnf install -y zenity cronie
                sudo systemctl enable --now crond
                ;;
            "zypper")
                echo "→ Detected zypper package manager"
                rpm -q zenity cronie &> /dev/null || sudo zypper install -y zenity cronie
                sudo systemctl enable --now cron
                ;;
            *)
                echo "✗ Unable to detect compatible package manager"
                echo ""
                echo "Please install manually:"
                echo "  - zenity (GUI toolkit)"
                echo "  - cron/cronie (cron daemon)"
                echo ""
                exit 1
                ;;
        esac
        ;;
esac

echo ""
echo "✓ All dependencies are installed!"
echo ""
