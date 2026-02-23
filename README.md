# Infrastructure as Code

Idempotent Ansible deployment for Passbolt password manager with **auto-updates via ansible-pull**, security hardening, and browser auto-fill capabilities.

## Overview

This repository contains infrastructure automation for deploying:
- **Passbolt** - Open source password manager
- **Auto-updates** - Ansible-pull runs every 30 minutes to keep server updated
- **Security hardening** - UFW, Fail2ban, kernel parameters, auto-updates
- **Auto-fill skill** - Browser automation for credential injection
- **Health monitoring** - Automatic recovery if services fail

## Quick Start (First Deploy)

```bash
# Clone and enter repository
git clone https://github.com/thomasgroch/infrastructure-as-code.git
cd infrastructure-as-code

# Run deployment (pre-configured for your domain)
make deploy

# After first deploy, ansible-pull maintains the server automatically
```

## Pre-Configured Settings

| Setting | Value |
|---------|-------|
| Domain | `pass.bot.stage.selections.buildaut.com.au` |
| Admin Email | `thomas@buildaut.com.au` |
| Admin Name | Thomas Buildaut |
| Auto-update | Every 30 minutes via ansible-pull |
| Health Check | Every 5 minutes via systemd timer |

## Auto-Update System (Ansible-Pull)

After the first deployment, the server **automatically updates itself** every 30 minutes:

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  GitHub     │────▶│  Ansible-Pull│────▶│  Your Server│
│  (source)   │     │  (every 30m) │     │  (target)   │
└─────────────┘     └──────────────┘     └─────────────┘
```

**How it works:**
1. Cron runs `/usr/local/bin/ansible-pull-wrapper` every 30 minutes
2. Script pulls latest code from `main` branch
3. Runs `ansible-playbook` with your configured variables
4. Logs to `/var/log/ansible-pull.log`

**To update your server manually:**
```bash
# Just push to GitHub - server updates automatically
# Or force immediate update:
sudo /usr/local/bin/ansible-pull-wrapper
```

**To check update logs:**
```bash
sudo tail -f /var/log/ansible-pull.log
```

## Health Monitoring

The system monitors Passbolt health every 5 minutes:

```bash
# View health check logs
sudo tail -f /var/log/passbolt-health.log

# Check systemd timer status
sudo systemctl status passbolt-health.timer
```

If Passbolt fails 3 consecutive checks, containers are automatically restarted.

## Requirements

- Ubuntu 22.04+ / Debian 12+
- Root or sudo access
- Domain `pass.bot.stage.selections.buildaut.com.au` pointed to server
- Ports 22, 80, 443 open

## Project Structure

```
.
├── ansible/
│   ├── inventory/           # Host inventory
│   ├── playbooks/
│   │   ├── site.yml         # Main deployment playbook
│   │   └── deploy.yml       # Auto-deploy playbook
│   ├── roles/               # Ansible roles
│   │   ├── common/          # System packages and security
│   │   ├── docker/          # Docker CE installation
│   │   ├── ssl/             # SSL/TLS configuration
│   │   ├── passbolt/        # Passbolt deployment
│   │   ├── firewall/        # UFW and Fail2ban
│   │   └── passbolt-autofill/  # Browser automation + ansible-pull
│   ├── group_vars/
│   │   └── all.yml          # Your configuration
│   └── ansible.cfg
├── tests/
│   └── run-tests.sh         # Integration test suite
├── Makefile
└── README.md
```

## Commands

```bash
# Deploy everything
make deploy

# Run tests only
make test

# Check deployment (dry-run)
make check

# Force immediate ansible-pull update
sudo /usr/local/bin/ansible-pull-wrapper

# View auto-update logs
sudo tail -f /var/log/ansible-pull.log

# View Passbolt logs
make logs

# SSH into Passbolt container
make shell

# Clean up (removes containers)
make clean
```

## Security Features

- **Firewall**: UFW with only 22, 80, 443 open
- **Intrusion detection**: Fail2ban for SSH and Passbolt
- **Docker security**: Seccomp, no-new-privileges, log limits
- **Kernel hardening**: ASLR, disabled ICMP redirects, martian logging
- **Auto-updates**: Unattended security upgrades + ansible-pull
- **SSL**: Automatic HTTPS via Caddy with security headers
- **Network isolation**: Internal Docker networks for database
- **Health monitoring**: Automatic recovery on failure

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
6. Ansible-pull configuration

Run with: `make test`

## Idempotency

All playbooks are **100% idempotent**:

```bash
# First run - creates everything
make deploy

# Second run - no changes (already configured)
make deploy

# Ansible-pull runs every 30min - only applies actual changes
```

## Making Changes

To modify the infrastructure:

1. **Edit files locally** or directly on GitHub
2. **Push to `main` branch**
3. **Server updates automatically** within 30 minutes
4. **Or force immediate update**: `sudo /usr/local/bin/ansible-pull-wrapper`

Example - adding a new environment variable:
```yaml
# Edit ansible/group_vars/all.yml
new_setting: "value"

# Commit and push
git add . && git commit -m "Add new setting" && git push

# Server updates automatically
```

## Troubleshooting

**Check ansible-pull status:**
```bash
sudo tail -20 /var/log/ansible-pull.log
```

**Force manual update:**
```bash
cd /opt/infrastructure-as-code
sudo git pull
sudo ansible-playbook -i ansible/inventory ansible/playbooks/site.yml
```

**Reset everything and redeploy:**
```bash
make clean
make deploy
```

## License

MIT - See LICENSE file
