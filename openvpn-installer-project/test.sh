#!/bin/bash
#
# Test script for OpenVPN installer
#
# Copyright (c) 2023 raayanTamuly
#

set -eo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored status
print_status() {
    local status=$1
    local message=$2
    
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}[PASS]${NC} $message"
    else
        echo -e "${RED}[FAIL]${NC} $message"
    fi
}

# Function to check script for syntax errors
check_syntax() {
    echo "Checking $1 for syntax errors..."
    
    if bash -n "$1"; then
        print_status "PASS" "Syntax check for $1"
        return 0
    else
        print_status "FAIL" "Syntax check for $1"
        return 1
    fi
}

# Function to check if required commands are available
check_commands() {
    echo "Checking for required commands..."
    local missing_commands=()
    
    for cmd in grep sed curl openssl; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [ ${#missing_commands[@]} -eq 0 ]; then
        print_status "PASS" "All required commands are available"
        return 0
    else
        print_status "FAIL" "Missing commands: ${missing_commands[*]}"
        return 1
    fi
}

# Main test sequence
echo "Starting tests for OpenVPN installer..."
echo "========================================"

# Check script syntax
if check_syntax "openvpn-installer.sh"; then
    syntax_check=0
else
    syntax_check=1
fi

# Check required commands
if check_commands; then
    commands_check=0
else
    commands_check=1
fi

# Check if client management script exists and has correct syntax
if [ -f "client-management.sh" ]; then
    if check_syntax "client-management.sh"; then
        client_script_check=0
    else
        client_script_check=1
    fi
else
    print_status "FAIL" "client-management.sh not found"
    client_script_check=1
fi

# Calculate overall test result
overall=$((syntax_check + commands_check + client_script_check))

echo "========================================"
if [ $overall -eq 0 ]; then
    print_status "PASS" "All tests passed!"
    exit 0
else
    print_status "FAIL" "$overall test(s) failed"
    exit 1
fi