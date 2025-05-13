# OpenVPN Installer Usage Guide

This guide provides detailed instructions for installing and using the OpenVPN Installer on various Linux distributions.

## Table of Contents

1. [Installation](#installation)
2. [Initial Setup](#initial-setup)
3. [Client Management](#client-management)
4. [Troubleshooting](#troubleshooting)
5. [Advanced Configuration](#advanced-configuration)

## Installation

### Prerequisites

- A server running a supported Linux distribution:
  - Ubuntu 18.04+
  - Debian 10+
  - AlmaLinux 8+
  - Rocky Linux 8+
  - CentOS 7+
  - Fedora 32+
  - openSUSE 15+
  - Amazon Linux 2
  - Raspberry Pi OS (Buster+)
- Root access or sudo privileges
- Basic knowledge of Linux terminal commands

### Download and Run the Installer

1. Download the installer script:
   ```bash
   curl -O https://raw.githubusercontent.com/SirCodeKnight/openvpn-installer/main/openvpn-installer.sh
   ```

2. Make the script executable:
   ```bash
   chmod +x openvpn-installer.sh
   ```

3. Run the script with root privileges:
   ```bash
   sudo ./openvpn-installer.sh
   ```

## Initial Setup

During the initial setup, you'll be prompted to:

1. **Confirm your public IPv4 address or hostname**
   - This should be automatically detected, but you can change it if needed
   - Use a domain name if you have one pointing to your server

2. **Choose a protocol**
   - UDP (recommended): Faster but might be blocked in some networks
   - TCP: More reliable in restrictive networks but slower

3. **Select a port**
   - Default: Random port between 10000-60000
   - You can specify a custom port if needed

4. **Choose DNS servers for clients**
   - Current system resolvers: Uses your server's DNS
   - Google: 8.8.8.8, 8.8.4.4
   - Cloudflare: 1.1.1.1, 1.0.0.1
   - OpenDNS: 208.67.222.222, 208.67.220.220
   - AdGuard DNS: 94.140.14.14, 94.140.15.15
   - Quad9: 9.9.9.9, 149.112.112.112

5. **Name your first client**
   - This will be used to create the first client configuration
   - Example: "phone", "laptop", "work", etc.

After completing these steps, the script will:
- Install OpenVPN and required dependencies
- Configure the OpenVPN server
- Set up the certificate authority
- Generate server and client certificates
- Configure networking and firewall rules
- Create your first client configuration

Once installation is complete, you'll find your client configuration files in:
```
/etc/openvpn/clients/[client_name]/
```

## Client Management

### Adding a New Client

To add a new client, run:
```bash
sudo ./openvpn-installer.sh --add-client
```

You'll be prompted to enter a name for the new client. After completion, the client configuration will be available in `/etc/openvpn/clients/[client_name]/`.

### Revoking a Client

To revoke a client's access, run:
```bash
sudo ./openvpn-installer.sh --revoke-client
```

You'll be shown a list of existing clients and prompted to enter the name of the client to revoke.

### Listing All Clients

To list all clients and their status, run:
```bash
sudo ./openvpn-installer.sh --list-clients
```

## Troubleshooting

### Connection Issues

If clients cannot connect to your VPN server:

1. **Check that the OpenVPN service is running**:
   ```bash
   sudo systemctl status openvpn-server@server
   ```

2. **Verify firewall settings**:
   ```bash
   sudo iptables -L -n
   ```

3. **Check that port forwarding is enabled**:
   ```bash
   cat /proc/sys/net/ipv4/ip_forward
   ```
   This should return `1`.

4. **Ensure your router/firewall is allowing the OpenVPN port**:
   - Forward the chosen port (UDP or TCP) to your server

5. **Check OpenVPN logs for errors**:
   ```bash
   sudo tail -f /var/log/syslog | grep openvpn
   ```

### Client Configuration Issues

If you're having problems with client configurations:

1. **Verify the configuration files are properly formatted**
2. **Check that the client software is compatible**
3. **Try both the regular and mobile configuration files**
4. **Ensure your server's IP address hasn't changed**

## Advanced Configuration

### Changing Server Settings

To modify advanced server settings:

1. Edit the server configuration file:
   ```bash
   sudo nano /etc/openvpn/server.conf
   ```

2. After making changes, restart the OpenVPN service:
   ```bash
   sudo systemctl restart openvpn-server@server
   ```

### Custom Client Configurations

To create custom client configurations:

1. Generate a basic client configuration:
   ```bash
   sudo ./openvpn-installer.sh --add-client
   ```

2. Edit the client configuration file:
   ```bash
   sudo nano /etc/openvpn/clients/[client_name]/[client_name].ovpn
   ```

3. Add custom options as needed, such as:
   - Static IP assignments
   - Split tunneling rules
   - Compression settings
   - Custom DNS settings

### Security Hardening

For additional security:

1. **Enable Two-Factor Authentication**:
   - Install the Google Authenticator PAM module
   - Configure OpenVPN to use it

2. **Implement IP filtering**:
   - Add firewall rules to limit connections to specific IP ranges

3. **Regular Updates**:
   - Keep your server and OpenVPN software updated
   - Monitor security advisories

---

For more information, visit the [GitHub repository](https://github.com/SirCodeKnight/openvpn-installer) or submit an issue if you encounter any problems.