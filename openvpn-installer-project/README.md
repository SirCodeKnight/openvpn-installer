# OpenVPN Installer

![OpenVPN Logo](https://raw.githubusercontent.com/SirCodeKnight/openvpn-installer/main/assets/openvpn-logo.png)

[![GitHub stars](https://img.shields.io/github/stars/SirCodeKnight/openvpn-installer.svg?style=for-the-badge)](https://github.com/SirCodeKnight/openvpn-installer/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/SirCodeKnight/openvpn-installer.svg?style=for-the-badge)](https://github.com/SirCodeKnight/openvpn-installer/network/members)
[![GitHub issues](https://img.shields.io/github/issues/SirCodeKnight/openvpn-installer.svg?style=for-the-badge)](https://github.com/SirCodeKnight/openvpn-installer/issues)
[![GitHub license](https://img.shields.io/github/license/SirCodeKnight/openvpn-installer.svg?style=for-the-badge)](https://github.com/SirCodeKnight/openvpn-installer/blob/main/LICENSE)

**A production-ready OpenVPN server installer for Linux distributions**

This script automates the installation and configuration of an OpenVPN server on various Linux distributions, making it easy to set up a secure VPN server in minutes.

## Supported Distributions

- Ubuntu 18.04+
- Debian 10+
- AlmaLinux 8+
- Rocky Linux 8+
- CentOS 7+
- Fedora 32+
- openSUSE 15+
- Amazon Linux 2
- Raspberry Pi OS (Buster and newer)

## Features

- **Easy Installation**: Set up a fully functional OpenVPN server in minutes
- **Secure by Default**: Uses modern encryption standards and secure configurations
- **Client Management**: Add, revoke, and list clients with simple commands
- **Mobile Compatible**: Creates configurations compatible with iOS and Android devices
- **NAT Configuration**: Automatically configures NAT for client traffic
- **DNS Options**: Choose from multiple DNS providers for your clients
- **Customizable**: Select your preferred port, protocol, and configuration options

## Quick Start

### Installation

```bash
# Download the script
curl -O https://raw.githubusercontent.com/SirCodeKnight/openvpn-installer/main/openvpn-installer.sh

# Make it executable
chmod +x openvpn-installer.sh

# Run it
sudo ./openvpn-installer.sh
```

The script will guide you through the setup process with prompts for:
- Public IPv4 address or hostname
- Protocol (UDP or TCP)
- Port number
- DNS servers for clients
- Name for the first client

After installation, client configuration files will be available in `/etc/openvpn/clients/[client_name]/`.

### Managing Clients

Add a new client:
```bash
sudo ./openvpn-installer.sh --add-client
```

Revoke a client:
```bash
sudo ./openvpn-installer.sh --revoke-client
```

List all clients:
```bash
sudo ./openvpn-installer.sh --list-clients
```

## Security Features

- TLS 1.2+ with modern ciphers
- AES-256-GCM encryption
- SHA512 authentication
- 4096-bit RSA keys for certificates
- Perfect Forward Secrecy
- TLS control channel encryption (tls-crypt)
- Client certificate verification

## Configuration Details

The server configuration uses:
- Port: Random between 10000-60000 (configurable)
- Protocol: UDP (default, configurable)
- Virtual network: 10.8.0.0/24
- Cipher: AES-256-GCM
- Authentication: SHA512
- DH parameters: 2048-bit
- TLS minimum version: 1.2
- Compression: LZ4-v2

## Troubleshooting

### Connection Issues

1. Verify that the OpenVPN service is running:
   ```bash
   sudo systemctl status openvpn-server@server
   ```

2. Check firewall rules:
   ```bash
   sudo iptables -L -n
   ```

3. Verify port forwarding is active:
   ```bash
   cat /proc/sys/net/ipv4/ip_forward
   ```
   Should return `1`.

4. Check OpenVPN logs:
   ```bash
   sudo tail -f /var/log/syslog | grep openvpn
   ```

### Client Configuration Issues

If clients cannot connect:

1. Verify the server's public IP has not changed
2. Check that the correct ports are open on your firewall/router
3. Ensure the client configuration file is complete and not corrupted

## Advanced Usage

### Custom DNS Configuration

You can modify the server configuration to use different DNS settings:

```bash
# Edit the server configuration
sudo nano /etc/openvpn/server.conf
```

Find the `push "dhcp-option DNS x.x.x.x"` lines and modify them with your preferred DNS servers.

### Server Hardening

For additional security:

1. Install fail2ban to prevent brute force attacks:
   ```bash
   sudo apt install fail2ban  # Debian/Ubuntu
   ```

2. Enable automatic security updates:
   ```bash
   sudo apt install unattended-upgrades  # Debian/Ubuntu
   ```

3. Configure server firewall with stricter rules

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- OpenVPN project and community
- Easy-RSA project
- All contributors who have helped improve this script

## Author

- [raayanTamuly](https://github.com/SirCodeKnight) - *Initial work and maintenance*

---

If you find this project useful, please consider giving it a star ⭐ on GitHub to show your support!