#!/bin/bash
#
# https://github.com/SirCodeKnight/openvpn-installer
#
# Copyright (c) 2023 raayanTamuly
#
# This script installs OpenVPN on various Linux distributions: Ubuntu, Debian, 
# AlmaLinux, Rocky Linux, CentOS, Fedora, openSUSE, Amazon Linux 2, and Raspberry Pi OS

# Detect Debian users running the script with "sh" instead of bash
if readlink /proc/$$/exe | grep -q "dash"; then
	echo 'This installer needs to be run with bash, not sh.'
	exit 1
fi

# Discard stdin. Needed when running from an one-liner which includes a newline
read -N 999999 -t 0.001

# Detect OpenVZ 6
if [[ $(uname -r | cut -d "." -f 1) -eq 2 ]]; then
	echo "The system is running an old kernel, which is incompatible with this installer."
	exit 1
fi

# Detect OS
# $os_version variables aren't always in use, but are kept here for convenience
if grep -qs "ubuntu" /etc/os-release; then
	os="ubuntu"
	os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
	group_name="nogroup"
elif [[ -e /etc/debian_version ]]; then
	os="debian"
	os_version=$(grep -oE '[0-9]+' /etc/debian_version | head -1)
	group_name="nogroup"
elif [[ -e /etc/almalinux-release || -e /etc/rocky-release || -e /etc/centos-release ]]; then
	os="centos"
	if grep -qs "AlmaLinux" /etc/os-release; then
		os_version=$(grep -shoE '[0-9]+' /etc/almalinux-release | head -1)
		os="almalinux"
	elif grep -qs "Rocky" /etc/os-release; then
		os_version=$(grep -shoE '[0-9]+' /etc/rocky-release | head -1)
		os="rocky"
	else
		os_version=$(grep -shoE '[0-9]+' /etc/centos-release | head -1)
	fi
	group_name="nobody"
elif [[ -e /etc/fedora-release ]]; then
	os="fedora"
	os_version=$(grep -oE '[0-9]+' /etc/fedora-release | head -1)
	group_name="nobody"
elif [[ -e /etc/opensuse-release ]]; then
	os="opensuse"
	os_version=$(grep -oE '[0-9]+' /etc/opensuse-release | head -1)
	group_name="nobody"
elif grep -qs "Amazon Linux" /etc/os-release; then
	os="amzn"
	if grep -q 'VERSION_ID="2"' /etc/os-release; then
		os_version="2"
	fi
	group_name="nobody"
elif grep -qs "Raspbian" /etc/os-release; then
	os="raspbian"
	os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
	group_name="nogroup"
else
	echo "This installer seems to be running on an unsupported distribution.
Supported distros are: Ubuntu, Debian, AlmaLinux, Rocky Linux, CentOS, Fedora, openSUSE, Amazon Linux 2, and Raspberry Pi OS"
	exit 1
fi

if [[ "$os" == "ubuntu" && "$os_version" -lt 1804 ]]; then
	echo "Ubuntu 18.04 or higher is required to use this installer.
This version of Ubuntu is too old and unsupported."
	exit 1
fi

if [[ "$os" == "debian" && "$os_version" -lt 10 ]]; then
	echo "Debian 10 or higher is required to use this installer.
This version of Debian is too old and unsupported."
	exit 1
fi

if [[ "$os" == "centos" && "$os_version" -lt 7 ]]; then
	echo "CentOS 7 or higher is required to use this installer.
This version of CentOS is too old and unsupported."
	exit 1
fi

if [[ "$os" == "almalinux" && "$os_version" -lt 8 ]]; then
	echo "AlmaLinux 8 or higher is required to use this installer.
This version of AlmaLinux is too old and unsupported."
	exit 1
fi

if [[ "$os" == "rocky" && "$os_version" -lt 8 ]]; then
	echo "Rocky Linux 8 or higher is required to use this installer.
This version of Rocky Linux is too old and unsupported."
	exit 1
fi

if [[ "$os" == "fedora" && "$os_version" -lt 32 ]]; then
	echo "Fedora 32 or higher is required to use this installer.
This version of Fedora is too old and unsupported."
	exit 1
fi

if [[ "$os" == "opensuse" && "$os_version" -lt 15 ]]; then
	echo "openSUSE 15 or higher is required to use this installer.
This version of openSUSE is too old and unsupported."
	exit 1
fi

if [[ "$os" == "amzn" && "$os_version" -lt 2 ]]; then
	echo "Amazon Linux 2 or higher is required to use this installer.
This version of Amazon Linux is too old and unsupported."
	exit 1
fi

if [[ "$os" == "raspbian" && "$os_version" -lt 10 ]]; then
	echo "Raspberry Pi OS (Buster) or higher is required to use this installer.
This version of Raspberry Pi OS is too old and unsupported."
	exit 1
fi

# Detect environments where $PATH does not include the sbin directories
if ! grep -q sbin <<< "$PATH"; then
	echo '$PATH does not include sbin. Try using "su -" instead of "su".'
	exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
	echo "This installer needs to be run with superuser privileges."
	exit 1
fi

if [[ ! -e /dev/net/tun ]] || ! ( exec 7<>/dev/net/tun ) 2>/dev/null; then
	echo "The system does not have the TUN device available.
TUN needs to be enabled before running this installer."
	exit 1
fi

# Check for systemd
if [[ ! -e /usr/bin/systemctl ]]; then
	echo "This installer requires systemd.
Your system does not appear to use systemd as its init system."
	exit 1
fi

# Check if OpenVPN is already installed
if [[ -e /etc/openvpn/server.conf || -e /etc/openvpn/server ]]; then
	echo "OpenVPN is already installed. This installer can be used to add or remove clients."
	exit 1
fi

new_client () {
	# Generate a client certificate
	client="$1"
	# Create client configuration directory if it doesn't exist
	mkdir -p /etc/openvpn/clients/"$client"
	
	# Generate client key and certificate
	cd /etc/openvpn/easy-rsa/ || return
	./easyrsa --batch --days=3650 build-client-full "$client" nopass
	
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
}

# Function to generate random port
random_port() {
	# Define port range (10000-60000)
	low=10000
	high=60000
	# Generate random port number
	port=$(shuf -i "${low}"-"${high}" -n 1)
	# Check if port is available
	if ss -tulpn | grep -q ":${port} "; then
		# If port is already in use, generate a new one
		random_port
	fi
	echo "$port"
}

# Initial setup
clear
echo "Welcome to the OpenVPN installer by raayanTamuly"
echo "GitHub repository: https://github.com/SirCodeKnight/openvpn-installer"
echo
echo "I need to ask you a few questions before starting the setup."
echo "You can leave the default options and just press enter if you are ok with them."
echo

# Determine public IPv4 address
ipv4_question="What is your public IPv4 address or hostname?"
ip=$(curl -4s https://api.ipify.org)
if [[ -z "$ip" ]]; then
	# Fallback to local ip route
	ip=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1)
fi

echo
echo "$ipv4_question"
read -p "Public IPv4 address or hostname [$ip]: " -e -i "$ip" ip
echo

# Choose protocol
echo "Which protocol should OpenVPN use?"
echo "   1) UDP (recommended, faster)"
echo "   2) TCP"
read -p "Protocol [1]: " -e -i 1 protocol_choice
case $protocol_choice in
	1)
		protocol="udp"
	;;
	2)
		protocol="tcp"
	;;
	*)
		protocol="udp"
	;;
esac
echo

# Determine port
echo "What port should OpenVPN listen on?"
read -p "Port [Randomized]: " -e -i "$(random_port)" port
echo

# DNS servers
echo "Which DNS server should clients use?"
echo "   1) Current system resolvers"
echo "   2) Google (8.8.8.8, 8.8.4.4)"
echo "   3) Cloudflare (1.1.1.1, 1.0.0.1)"
echo "   4) OpenDNS (208.67.222.222, 208.67.220.220)"
echo "   5) AdGuard DNS (94.140.14.14, 94.140.15.15)"
echo "   6) Quad9 (9.9.9.9, 149.112.112.112)"
read -p "DNS [1]: " -e -i 1 dns
echo

# Name the first client
echo "Enter a name for the first client:"
read -p "Name [client]: " -e -i "client" unsanitized_client
# Sanitize client name
client=$(sed 's/[^0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$unsanitized_client")
[[ -z "$client" ]] && client="client"
echo

# Installation begins
echo "Installing OpenVPN..."

# Install necessary packages based on OS
case "$os" in
	ubuntu|debian|raspbian)
		apt-get update
		apt-get -y install ca-certificates gnupg
		if [[ "$os" == "ubuntu" ]]; then
			# Ubuntu specific - add OpenVPN repository
			apt-get -y install software-properties-common
			add-apt-repository -y universe
		fi
		apt-get update
		apt-get -y install openvpn openssl easy-rsa iptables-persistent netfilter-persistent
	;;
	centos|almalinux|rocky)
		yum -y install epel-release
		yum -y install openvpn openssl easy-rsa iptables-services
		# Enable iptables service
		systemctl enable --now iptables
	;;
	fedora)
		dnf -y install openvpn openssl easy-rsa iptables-services
		# Enable iptables service
		systemctl enable --now iptables
	;;
	opensuse)
		zypper -n install openvpn openssl easy-rsa iptables
		# Enable iptables service
		systemctl enable --now iptables
	;;
	amzn)
		amazon-linux-extras install -y epel
		yum -y install openvpn openssl easy-rsa iptables-services
		# Enable iptables service
		systemctl enable --now iptables
	;;
esac

# Setup OpenVPN directories
mkdir -p /etc/openvpn/clients
mkdir -p /etc/openvpn/easy-rsa

# Get easyrsa
easyrsa_version="3.1.2"
wget -O ~/easy-rsa.tgz https://github.com/OpenVPN/easy-rsa/releases/download/v${easyrsa_version}/EasyRSA-${easyrsa_version}.tgz
tar xzf ~/easy-rsa.tgz --strip-components=1 --directory /etc/openvpn/easy-rsa
rm ~/easy-rsa.tgz

# Create PKI directory
cd /etc/openvpn/easy-rsa/ || exit
./easyrsa init-pki
./easyrsa --batch --days=3650 build-ca nopass
./easyrsa --batch --days=3650 gen-dh
./easyrsa --batch --days=3650 build-server-full server nopass

# Create tls-crypt key
openvpn --genkey --secret /etc/openvpn/tls-crypt.key

# Configure the server
{
echo "# OpenVPN server configuration"
echo "port $port"
echo "proto $protocol"
echo "dev tun"
echo "user nobody"
echo "group $group_name"
echo "persist-key"
echo "persist-tun"
echo "keepalive 10 120"
echo "topology subnet"
echo "server 10.8.0.0 255.255.255.0"
echo "ifconfig-pool-persist ipp.txt"
echo "push \"redirect-gateway def1 bypass-dhcp\""

# DNS settings
case $dns in
	1)
		# Locate the proper resolv.conf
		if grep -q "127.0.0.53" "/etc/resolv.conf"; then
			resolv_conf="/run/systemd/resolve/resolv.conf"
		else
			resolv_conf="/etc/resolv.conf"
		fi
		# Get the resolvers from resolv.conf
		grep -v '#' $resolv_conf | grep nameserver | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
			echo "push \"dhcp-option DNS $line\""
		done
	;;
	2)
		echo 'push "dhcp-option DNS 8.8.8.8"'
		echo 'push "dhcp-option DNS 8.8.4.4"'
	;;
	3)
		echo 'push "dhcp-option DNS 1.1.1.1"'
		echo 'push "dhcp-option DNS 1.0.0.1"'
	;;
	4)
		echo 'push "dhcp-option DNS 208.67.222.222"'
		echo 'push "dhcp-option DNS 208.67.220.220"'
	;;
	5)
		echo 'push "dhcp-option DNS 94.140.14.14"'
		echo 'push "dhcp-option DNS 94.140.15.15"'
	;;
	6)
		echo 'push "dhcp-option DNS 9.9.9.9"'
		echo 'push "dhcp-option DNS 149.112.112.112"'
	;;
esac

echo "dh /etc/openvpn/easy-rsa/pki/dh.pem"
echo "ca /etc/openvpn/easy-rsa/pki/ca.crt"
echo "cert /etc/openvpn/easy-rsa/pki/issued/server.crt"
echo "key /etc/openvpn/easy-rsa/pki/private/server.key"
echo "tls-crypt /etc/openvpn/tls-crypt.key"
echo "auth SHA512"
echo "cipher AES-256-GCM"
echo "tls-server"
echo "tls-version-min 1.2"
echo "tls-cipher TLS-ECDHE-ECDSA-WITH-AES-256-GCM-SHA384"
echo "compress lz4-v2"
echo "push \"compress lz4-v2\""
echo "duplicate-cn"
echo "max-clients 100"
echo "status openvpn-status.log"
echo "verb 3"
} > /etc/openvpn/server.conf

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-openvpn.conf
sysctl --system

# Setup firewall rules
if [[ "$os" == "ubuntu" || "$os" == "debian" || "$os" == "raspbian" ]]; then
	# Ubuntu/Debian
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$interface" -j MASQUERADE
	iptables -A INPUT -i tun0 -j ACCEPT
	iptables -A FORWARD -i "$interface" -o tun0 -j ACCEPT
	iptables -A FORWARD -i tun0 -o "$interface" -j ACCEPT
	iptables -A INPUT -i "$interface" -p "$protocol" --dport "$port" -j ACCEPT
	
	# Save iptables rules
	netfilter-persistent save
elif [[ "$os" == "centos" || "$os" == "almalinux" || "$os" == "rocky" || "$os" == "fedora" || "$os" == "amzn" ]]; then
	# CentOS/RHEL-based
	firewall-cmd --permanent --add-service=openvpn
	firewall-cmd --permanent --zone=trusted --add-service=openvpn
	firewall-cmd --permanent --zone=trusted --add-interface=tun0
	firewall-cmd --permanent --add-port="$port"/"$protocol"
	firewall-cmd --permanent --add-masquerade
	firewall-cmd --reload
	
	# Save iptables rules
	service iptables save
elif [[ "$os" == "opensuse" ]]; then
	# openSUSE
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$interface" -j MASQUERADE
	iptables -A INPUT -i tun0 -j ACCEPT
	iptables -A FORWARD -i "$interface" -o tun0 -j ACCEPT
	iptables -A FORWARD -i tun0 -o "$interface" -j ACCEPT
	iptables -A INPUT -i "$interface" -p "$protocol" --dport "$port" -j ACCEPT
	
	# Save iptables rules
	systemctl enable iptables
	systemctl restart iptables
fi

# Enable and start OpenVPN service
systemctl enable --now openvpn-server@server

# Generate client configuration
new_client "$client"

# Show success message and client configuration
clear
echo "Your OpenVPN server is now ready!"
echo
echo "Client configuration files are available at: /etc/openvpn/clients/$client/"
echo
echo "To add more clients, run: $0 --add-client"
echo "To revoke clients, run: $0 --revoke-client"
echo "To list all clients, run: $0 --list-clients"
echo
echo "Script maintained by raayanTamuly"
echo "GitHub: https://github.com/SirCodeKnight/openvpn-installer"