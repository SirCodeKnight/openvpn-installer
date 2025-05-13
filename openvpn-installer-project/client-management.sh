#!/bin/bash
#
# https://github.com/SirCodeKnight/openvpn-installer
#
# Copyright (c) 2023 raayanTamuly
#
# Client management script for OpenVPN

# Detect Debian users running the script with "sh" instead of bash
if readlink /proc/$$/exe | grep -q "dash"; then
    echo 'This script needs to be run with bash, not sh.'
    exit 1
fi

# Ensure running as root
if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Check if OpenVPN is installed
if [[ ! -e /etc/openvpn/server.conf ]]; then
    echo "OpenVPN is not installed. Please run the installer first."
    exit 1
fi

# Function to add a new client
add_client() {
    echo "Enter a name for the new client:"
    read -p "Name [client]: " -e -i "client" unsanitized_client
    
    # Sanitize client name
    client=$(sed 's/[^0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$unsanitized_client")
    [[ -z "$client" ]] && client="client"
    
    # Check if client already exists
    if [[ -e /etc/openvpn/easy-rsa/pki/issued/"$client".crt ]]; then
        echo "Client '$client' already exists. Please choose a different name."
        exit 1
    fi
    
    # Get server protocol and port
    protocol=$(grep -E "^proto " /etc/openvpn/server.conf | cut -d ' ' -f 2)
    port=$(grep -E "^port " /etc/openvpn/server.conf | cut -d ' ' -f 2)
    
    # Get public IP
    ip=$(curl -4s https://api.ipify.org)
    if [[ -z "$ip" ]]; then
        # Fallback to local ip route
        ip=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1)
    fi
    
    # Generate client certificate
    cd /etc/openvpn/easy-rsa/ || exit
    ./easyrsa --batch --days=3650 build-client-full "$client" nopass
    
    # Create client configuration directory
    mkdir -p /etc/openvpn/clients/"$client"
    
    # Generate client configuration
    {
    echo "client"
    echo "dev tun"
    echo "proto $protocol"
    echo "remote $ip $port"
    echo "resolv-retry infinite"
    echo "nobind"
    echo "persist-key"
    echo "persist-tun"
    echo "remote-cert-tls server"
    echo "verify-x509-name server name"
    echo "auth SHA512"
    echo "cipher AES-256-GCM"
    echo "tls-client"
    echo "tls-version-min 1.2"
    echo "tls-cipher TLS-ECDHE-ECDSA-WITH-AES-256-GCM-SHA384"
    echo "ignore-unknown-option block-outside-dns"
    echo "block-outside-dns"
    echo "verb 3"
    echo "compress lz4-v2"
    echo "reneg-sec 0"
    echo "<ca>"
    cat /etc/openvpn/easy-rsa/pki/ca.crt
    echo "</ca>"
    echo "<cert>"
    cat /etc/openvpn/easy-rsa/pki/issued/"$client".crt
    echo "</cert>"
    echo "<key>"
    cat /etc/openvpn/easy-rsa/pki/private/"$client".key
    echo "</key>"
    echo "<tls-crypt>"
    cat /etc/openvpn/tls-crypt.key
    echo "</tls-crypt>"
    } > /etc/openvpn/clients/"$client"/"$client".ovpn
    
    # Create individual files for mobile clients
    cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/clients/"$client"/
    cp /etc/openvpn/easy-rsa/pki/issued/"$client".crt /etc/openvpn/clients/"$client"/
    cp /etc/openvpn/easy-rsa/pki/private/"$client".key /etc/openvpn/clients/"$client"/
    cp /etc/openvpn/tls-crypt.key /etc/openvpn/clients/"$client"/
    
    # Create a mobile-friendly config
    {
    echo "client"
    echo "dev tun"
    echo "proto $protocol"
    echo "remote $ip $port"
    echo "resolv-retry infinite"
    echo "nobind"
    echo "persist-key"
    echo "persist-tun"
    echo "remote-cert-tls server"
    echo "verify-x509-name server name"
    echo "auth SHA512"
    echo "cipher AES-256-GCM"
    echo "tls-client"
    echo "tls-version-min 1.2"
    echo "tls-cipher TLS-ECDHE-ECDSA-WITH-AES-256-GCM-SHA384"
    echo "ignore-unknown-option block-outside-dns"
    echo "block-outside-dns"
    echo "verb 3"
    echo "compress lz4-v2"
    echo "reneg-sec 0"
    echo "ca ca.crt"
    echo "cert $client.crt"
    echo "key $client.key"
    echo "tls-crypt tls-crypt.key"
    } > /etc/openvpn/clients/"$client"/"$client"_mobile.ovpn
    
    echo "Client '$client' added. Configuration is available at /etc/openvpn/clients/$client/"
}

# Function to revoke a client
revoke_client() {
    # Check if there are any clients
    if [[ ! -d /etc/openvpn/easy-rsa/pki/issued ]]; then
        echo "There are no clients to revoke."
        exit 1
    fi
    
    # List available clients
    echo "Available clients:"
    echo
    ls /etc/openvpn/easy-rsa/pki/issued/ | grep -v "server.crt" | sed 's/\.crt$//'
    echo
    
    # Prompt for client to revoke
    read -p "Enter client name to revoke: " client
    
    # Check if client exists
    if [[ ! -f /etc/openvpn/easy-rsa/pki/issued/"$client".crt ]]; then
        echo "Client '$client' does not exist."
        exit 1
    fi
    
    # Revoke client certificate
    cd /etc/openvpn/easy-rsa/ || exit
    ./easyrsa --batch revoke "$client"
    ./easyrsa --batch gen-crl
    
    # Replace the CRL file
    rm -f /etc/openvpn/crl.pem
    cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/
    
    # Remove client configuration
    rm -rf /etc/openvpn/clients/"$client"
    
    # Update OpenVPN configuration to use CRL if not already set
    if ! grep -q "crl-verify" /etc/openvpn/server.conf; then
        echo "crl-verify /etc/openvpn/crl.pem" >> /etc/openvpn/server.conf
        systemctl restart openvpn-server@server
    fi
    
    echo "Client '$client' has been revoked."
}

# Function to list all clients
list_clients() {
    # Check if there are any clients
    if [[ ! -d /etc/openvpn/easy-rsa/pki/issued ]]; then
        echo "No clients have been created yet."
        exit 1
    fi
    
    echo "=== OpenVPN Clients ==="
    echo
    
    # Get all client certificates
    clients=$(ls /etc/openvpn/easy-rsa/pki/issued/ | grep -v "server.crt" | sed 's/\.crt$//')
    
    if [[ -z "$clients" ]]; then
        echo "No clients have been created yet."
        exit 1
    fi
    
    # Check for CRL to identify revoked clients
    if [[ -f /etc/openvpn/easy-rsa/pki/crl.pem ]]; then
        # Extract revoked client serial numbers
        revoked_serials=$(openssl crl -in /etc/openvpn/easy-rsa/pki/crl.pem -noout -text | grep "Serial Number:" | awk '{print $3}')
    fi
    
    # Print client status
    for client in $clients; do
        # Get client certificate serial number
        serial=$(openssl x509 -in /etc/openvpn/easy-rsa/pki/issued/"$client".crt -noout -serial | cut -d= -f2)
        
        # Check if client is revoked
        revoked=false
        for rev_serial in $revoked_serials; do
            if [[ "$serial" == "$rev_serial" ]]; then
                revoked=true
                break
            fi
        done
        
        # Print client with status
        if $revoked; then
            echo "$client (REVOKED)"
        else
            echo "$client (ACTIVE)"
        fi
    done
}

# Parse command line arguments
case "$1" in
    --add|--add-client)
        add_client
        ;;
    --revoke|--revoke-client)
        revoke_client
        ;;
    --list|--list-clients)
        list_clients
        ;;
    *)
        echo "Usage: $0 {--add-client|--revoke-client|--list-clients}"
        exit 1
        ;;
esac