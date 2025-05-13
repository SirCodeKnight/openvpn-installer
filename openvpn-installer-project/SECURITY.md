# Security Policy

## Supported Versions

Use this section to tell people about which versions of your project are currently being supported with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please send an email to the project maintainer. All security vulnerabilities will be promptly addressed.

Please include the following information in your report:

- Type of issue (e.g. buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit the issue

This information will help us triage your report more quickly.

## Security Measures

This installer implements the following security measures:

- Uses modern cryptographic standards (AES-256-GCM)
- Implements Perfect Forward Secrecy
- Enables TLS 1.2+ with secure ciphers
- Uses SHA512 for authentication
- Implements TLS control channel encryption
- Creates unique certificates for server and clients
- Follows OpenVPN security best practices

## Security Update Process

Security updates will be released as patch versions and announced via:

1. GitHub releases
2. Commit messages
3. README updates

We recommend always using the most recent version of the installer.