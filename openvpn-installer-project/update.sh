#!/bin/bash
#
# Update script for OpenVPN installer
#
# Copyright (c) 2023 raayanTamuly
#

# Check if running as root
if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

echo "OpenVPN Installer Updater"
echo "========================="
echo

# Define repository and branch
REPO="SirCodeKnight/openvpn-installer"
BRANCH="main"

# Get current directory
CURRENT_DIR=$(pwd)

# Create a temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || exit 1

echo "Downloading latest version..."
# Download latest version from GitHub
curl -sLO "https://raw.githubusercontent.com/${REPO}/${BRANCH}/openvpn-installer.sh"
curl -sLO "https://raw.githubusercontent.com/${REPO}/${BRANCH}/client-management.sh"

# Make scripts executable
chmod +x openvpn-installer.sh
chmod +x client-management.sh

echo "Checking for OpenVPN configuration..."
# Check if OpenVPN is already installed
if [[ -e /etc/openvpn/server.conf ]]; then
    echo "OpenVPN is already installed. Backing up configuration..."
    # Backup current configuration
    BACKUP_DIR="/etc/openvpn/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r /etc/openvpn/* "$BACKUP_DIR"
    echo "Configuration backed up to $BACKUP_DIR"
fi

echo "Installing updated scripts..."
# Move scripts to final location
cp openvpn-installer.sh "$CURRENT_DIR/"
cp client-management.sh "$CURRENT_DIR/"

# Clean up
cd "$CURRENT_DIR" || exit 1
rm -rf "$TMP_DIR"

echo "Update completed successfully!"
echo "You can now run ./openvpn-installer.sh to use the updated version."
echo