#!/bin/bash
# =============================================================================
# AI Model Backup Script
# Author: HER (0604.ai)
# Last Updated: 2026-06-19
# =============================================================================

set -euo pipefail

BACKUP_DIR="/backup/ollama"
RETENTION_DAYS=7
LOG_FILE="/var/log/ai-backup.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

success() { log "✓ $1"; }
warn() { log "⚠ $1"; }
error() { log "✗ $1"; }

# Create backup directory
mkdir -p "$BACKUP_DIR"

log "========================================"
log "Starting AI model backup: $TIMESTAMP"
log "========================================"

# =============================================================================
# BACKUP 1: Ollama Models
# =============================================================================
log "Backing up Ollama models..."

OLLAMA_MODELS="/usr/share/ollama/.ollama/models"
if [[ -d "$OLLAMA_MODELS" ]]; then
    tar -czf "$BACKUP_DIR/ollama-models-$TIMESTAMP.tar.gz" \
        -C "$(dirname "$OLLAMA_MODELS")" \
        "$(basename "$OLLAMA_MODELS")" 2>/dev/null || \
        warn "Could not backup Ollama models (may need sudo)"
    success "Ollama models backed up"
else
    warn "Ollama models directory not found at $OLLAMA_MODELS"
fi

# =============================================================================
# BACKUP 2: Ollama Configuration
# =============================================================================
log "Backing up Ollama configuration..."

if [[ -d /etc/ollama ]]; then
    tar -czf "$BACKUP_DIR/ollama-config-$TIMESTAMP.tar.gz" /etc/ollama 2>/dev/null || \
        warn "Could not backup Ollama config"
    success "Ollama configuration backed up"
fi

# =============================================================================
# BACKUP 3: Open WebUI Data
# =============================================================================
log "Backing up Open WebUI data..."

WEBUI_DATA="/opt/open-webui/data"
if [[ -d "$WEBUI_DATA" ]]; then
    # Stop container briefly for consistent backup
    docker stop open-webui 2>/dev/null || true
    
    tar -czf "$BACKUP_DIR/webui-data-$TIMESTAMP.tar.gz" "$WEBUI_DATA" 2>/dev/null || \
        warn "Could not backup WebUI data"
    
    docker start open-webui 2>/dev/null || true
    success "Open WebUI data backed up"
else
    warn "Open WebUI data directory not found"
fi

# =============================================================================
# BACKUP 4: Custom Scripts & Configs
# =============================================================================
log "Backing up custom scripts..."

if [[ -d /opt/ai-scripts ]]; then
    tar -czf "$BACKUP_DIR/custom-scripts-$TIMESTAMP.tar.gz" /opt/ai-scripts 2>/dev/null || \
        warn "Could not backup custom scripts"
    success "Custom scripts backed up"
fi

# =============================================================================
# BACKUP 5: System Configuration
# =============================================================================
log "Backing up system configuration..."

tar -czf "$BACKUP_DIR/system-config-$TIMESTAMP.tar.gz" \
    /etc/ssh/sshd_config \
    /etc/ssh/sshd_config.d/ \
    /etc/ufw/ \
    /etc/fail2ban/ \
    /etc/docker/ \
    2>/dev/null || warn "Some system configs could not be backed up"

success "System configuration backed up"

# =============================================================================
# CLEANUP OLD BACKUPS
# =============================================================================
log "Cleaning up backups older than $RETENTION_DAYS days..."

DELETED=$(find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete -print | wc -l)
log "Removed $DELETED old backup files"

# =============================================================================
# BACKUP SUMMARY
# =============================================================================
echo
log "========================================"
log "BACKUP SUMMARY: $TIMESTAMP"
log "========================================"

for file in "$BACKUP_DIR"/*-$TIMESTAMP.tar.gz; do
    if [[ -f "$file" ]]; then
        SIZE=$(du -h "$file" | cut -f1)
        log "  $(basename "$file"): $SIZE"
    fi
done

TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
log "Total backup size: $TOTAL_SIZE"
log "Backup location: $BACKUP_DIR"
log "========================================"

# Optional: Sync to remote (uncomment and configure as needed)
# log "Syncing to remote backup..."
# rsync -avz "$BACKUP_DIR/" backup-server:/backups/ai-server/ 2>/dev/null || \
#     warn "Remote sync failed (check SSH keys and connectivity)"

success "Backup complete!"
