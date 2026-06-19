#!/bin/bash
# =============================================================================
# Ubuntu Security Hardening Script for AI Servers
# For: Ubuntu 24.04 LTS
# Author: HER (0604.ai)
# Last Updated: 2026-06-19
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
   exit 1
fi

log "Starting security hardening..."

# =============================================================================
# SSH HARDENING
# =============================================================================
log "Hardening SSH..."

# Backup original config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d)

# Apply hardening
cat > /etc/ssh/sshd_config.d/ai-server.conf << 'EOF'
# AI Server SSH Hardening
# Disable root login
PermitRootLogin no

# Disable password authentication (use keys only)
PasswordAuthentication no

# Use only SSH keys
PubkeyAuthentication yes

# Disable empty passwords
PermitEmptyPasswords no

# Limit authentication attempts
MaxAuthTries 3

# Set idle timeout
ClientAliveInterval 300
ClientAliveCountMax 2

# Allow only specific users (uncomment and modify as needed)
# AllowUsers admin wmorris

# Use strong algorithms only
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Disable X11 forwarding
X11Forwarding no

# Disable TCP forwarding for non-admin users (optional)
# AllowTcpForwarding no
EOF

# Ensure SSH key exists for current admin
if [[ ! -f /root/.ssh/authorized_keys ]] && [[ ! -f /home/*/.ssh/authorized_keys ]]; then
    warn "No SSH authorized_keys found. Make sure you have SSH keys set up before disabling passwords!"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

systemctl restart sshd
success "SSH hardened"

# =============================================================================
# INSTALL FAIL2BAN
# =============================================================================
log "Installing fail2ban..."

apt install -y fail2ban

# Configure fail2ban for SSH
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
# Ban IP for 1 hour after 3 failed attempts
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[ollama]
enabled = true
port = 11434
filter = ollama
logpath = /var/log/ollama.log
maxretry = 5
bantime = 1800
EOF

# Create Ollama filter
cat > /etc/fail2ban/filter.d/ollama.conf << 'EOF'
[Definition]
failregex = ^.*Failed authentication attempt from <HOST>.*$
            ^.*Unauthorized access from <HOST>.*$
ignoreregex =
EOF

systemctl enable fail2ban
systemctl restart fail2ban
success "Fail2ban configured"

# =============================================================================
# AUTOMATIC SECURITY UPDATES
# =============================================================================
log "Configuring automatic security updates..."

apt install -y unattended-upgrades

cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::InstallOnShutdown "false";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

success "Automatic security updates configured"

# =============================================================================
# KERNEL HARDENING (SYSCTL)
# =============================================================================
log "Applying kernel hardening..."

cat > /etc/sysctl.d/99-ai-server.conf << 'EOF'
# Disable IP source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0

# Enable SYN cookies (SYN flood protection)
net.ipv4.tcp_syncookies = 1

# Disable IPv6 if not needed (uncomment if not using IPv6)
# net.ipv6.conf.all.disable_ipv6 = 1
# net.ipv6.conf.default.disable_ipv6 = 1

# Increase connection tracking table
net.netfilter.nf_conntrack_max = 65536

# Enable ASLR
kernel.randomize_va_space = 2

# Restrict dmesg access
kernel.dmesg_restrict = 1

# Disable core dumps
fs.suid_dumpable = 0
EOF

sysctl --system
success "Kernel hardening applied"

# =============================================================================
# AUDIT LOGGING
# =============================================================================
log "Setting up audit logging..."

apt install -y auditd

# Monitor critical files
cat > /etc/audit/rules.d/ai-server.rules << 'EOF'
# Monitor AI model files
-w /usr/share/ollama/ -p wa -k ollama_models

# Monitor configuration files
-w /etc/ollama/ -p wa -k ollama_config

# Monitor user access
-w /etc/passwd -p wa -k identity_changes
-w /etc/group -p wa -k identity_changes

# Monitor SSH config
-w /etc/ssh/ -p wa -k ssh_config

# Monitor sudoers
-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d/ -p wa -k sudoers
EOF

systemctl enable auditd
systemctl restart auditd
success "Audit logging configured"

# =============================================================================
# DISABLE UNNECESSARY SERVICES
# =============================================================================
log "Disabling unnecessary services..."

SERVICES_TO_DISABLE=(
    "cups"
    "avahi-daemon"
    "bluetooth"
    "snapd"
)

for service in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl is-enabled "$service" 2>/dev/null | grep -q "enabled"; then
        systemctl disable "$service" 2>/dev/null || true
        systemctl stop "$service" 2>/dev/null || true
        log "Disabled $service"
    fi
done

success "Unnecessary services disabled"

# =============================================================================
# FILE PERMISSIONS
# =============================================================================
log "Setting secure file permissions..."

# Secure Ollama directories
chmod 750 /usr/share/ollama/ 2>/dev/null || true
chmod 700 /root/.ssh 2>/dev/null || true
chmod 600 /root/.ssh/authorized_keys 2>/dev/null || true

# Secure log files
chmod 640 /var/log/auth.log 2>/dev/null || true
chmod 640 /var/log/syslog 2>/dev/null || true

success "File permissions set"

# =============================================================================
# COMPLETION
# =============================================================================
echo
success "=========================================="
success "  Security Hardening Complete!"
success "=========================================="
echo
log "Summary of changes:"
echo "  • SSH key-only authentication configured"
echo "  • Fail2ban installed (3 strikes = 1 hour ban)"
echo "  • Automatic security updates enabled"
echo "  • Kernel hardening applied"
echo "  • Audit logging configured"
echo "  • Unnecessary services disabled"
echo
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "1. If you haven't set up SSH keys, do so NOW before logging out"
echo "2. Test SSH access in a new terminal before closing this session"
echo "3. Review /etc/ssh/sshd_config.d/ai-server.conf for customization"
echo "4. Check fail2ban status: sudo fail2ban-client status"
echo
log "Run 'sudo reboot' to apply all changes"
