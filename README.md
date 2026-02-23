# Infrastructure as Code

Idempotent Ansible deployment for Passbolt password manager with security hardening and browser auto-fill capabilities.

## Overview

This repository contains infrastructure automation for deploying:
- **Passbolt** - Open source password manager
- **Security hardening** - UFW, Fail2ban, kernel parameters, auto-updates
- **Auto-fill skill** - Browser automation for credential injection

## Quick Start

```bash
# Clone and enter repository
git clone https://github.com/YOUR_USERNAME/infrastructure-as-code.git
cd infrastructure-as-code

# Set environment variables
export PASSBOLT_DOMAIN=passbolt.yourdomain.com
export PASSBOLT_ADMIN_EMAIL=admin@yourdomain.com

# Run deployment
make deploy

# Run tests
make test
```

## Requirements

- Ubuntu 22.04+ / Debian 12+
- Ansible 2.14+
- Root or sudo access
- Domain pointed to server (for SSL)

## Project Structure

```
.
├── ansible/
│   ├── inventory/           # Host inventory
│   ├── playbooks/
│   │   └── site.yml         # Main deployment playbook
│   ├── roles/               # Ansible roles
│   │   ├── common/          # System packages and security basics
│   │   ├── docker/          # Docker installation
│   │   ├── ssl/             # SSL/TLS configuration
│   │   ├── passbolt/        # Passbolt deployment
│   │   ├── firewall/        # UFW and Fail2ban
│   │   └── passbolt-autofill/  # Browser automation skill
│   └── group_vars/
│       └── all.yml          # Configuration variables
├── tests/
│   └── run-tests.sh         # Integration test suite
├── Makefile                 # Common tasks
└── README.md               # This file
```

## Configuration

Configuration is done via environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `PASSBOLT_DOMAIN` | Domain for Passbolt | `passbolt.local` |
| `PASSBOLT_ADMIN_EMAIL` | Admin email | `admin@passbolt.local` |
| `PASSBOLT_ADMIN_FIRST_NAME` | Admin first name | `Admin` |
| `PASSBOLT_ADMIN_LAST_NAME` | Admin last name | `User` |
| `SMTP_HOST` | SMTP server | (none) |
| `SMTP_PORT` | SMTP port | `587` |
| `SMTP_USER` | SMTP username | (none) |
| `SMTP_PASSWORD` | SMTP password | (none) |
| `SSH_PORT` | SSH port | `22` |

## Commands

```bash
# Deploy everything
make deploy

# Run tests only
make test

# Check deployment (dry-run)
make check

# Clean up (removes containers)
make clean

# View logs
make logs

# SSH into Passbolt container
make shell
```

## Security Features

- **Firewall**: UFW with only 22, 80, 443 open
- **Intrusion detection**: Fail2ban for SSH and Passbolt
- **Docker security**: Seccomp, no-new-privileges, log limits
- **Kernel hardening**: ASLR, disabled ICMP redirects, martian logging
- **Auto-updates**: Unattended security upgrades
- **SSL**: Automatic HTTPS via Caddy with security headers
- **Network isolation**: Internal Docker networks for database

## Passbolt Auto-fill Skill

Browser automation for automatic credential filling:

```bash
# Check Passbolt health
passbolt-autofill health

# Search for credentials
passbolt-autofill search "github"

# Auto-fill a login form
passbolt-autofill fill "https://github.com/login" "github-account"

# Run tests
passbolt-autofill test
```

## Testing

The test suite validates:
1. System security (firewall, fail2ban, kernel params)
2. Docker infrastructure (containers, networks)
3. Passbolt application (health, SSL, headers)
4. Auto-fill skill (scripts, dependencies, connectivity)
5. Network security (port exposure)

Run with: `make test`

## Idempotency

All playbooks are idempotent - running multiple times produces the same result without side effects:

```bash
# First run - creates everything
make deploy

# Second run - verifies no changes needed
make deploy

# Third run - same result
make deploy
```

## License

MIT - See LICENSE file
