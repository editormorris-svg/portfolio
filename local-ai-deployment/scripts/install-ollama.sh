#!/bin/bash
# =============================================================================
# Secure Local AI Deployment - Full Installation Script
# For: Ubuntu 24.04 LTS
# Author: HER (0604.ai)
# Last Updated: 2026-06-19
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should NOT be run as root for security reasons"
   error "Run as a regular user with sudo privileges"
   exit 1
fi

# Check Ubuntu version
if ! grep -q "Ubuntu 24.04" /etc/os-release; then
    warn "This script is tested on Ubuntu 24.04 LTS"
    warn "Your OS may differ. Continue at your own risk."
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

log "Starting Secure Local AI deployment..."

# =============================================================================
# STEP 1: System Update
# =============================================================================
log "Step 1/6: Updating system packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    curl \
    wget \
    git \
    htop \
    vim \
    tmux \
    unzip \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg

success "System updated"

# =============================================================================
# STEP 2: Install Ollama
# =============================================================================
log "Step 2/6: Installing Ollama..."

if command -v ollama &> /dev/null; then
    warn "Ollama already installed. Skipping..."
else
    curl -fsSL https://ollama.com/install.sh | sh
    success "Ollama installed"
fi

# Start Ollama service
sudo systemctl enable ollama
sudo systemctl start ollama

# Wait for Ollama to be ready
sleep 5
if ! systemctl is-active --quiet ollama; then
    error "Ollama service failed to start"
    exit 1
fi
success "Ollama service running"

# =============================================================================
# STEP 3: Pull Recommended Models
# =============================================================================
log "Step 3/6: Pulling recommended models..."

# Check available VRAM to determine which models to pull
VRAM_GB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | awk '{print int($1/1024)}' || echo "0")

if [[ $VRAM_GB -ge 16 ]]; then
    log "Detected ${VRAM_GB}GB VRAM. Pulling large models..."
    MODELS=("qwen2.5:7b" "llama3.1:8b" "mistral:7b" "nomic-embed-text")
elif [[ $VRAM_GB -ge 8 ]]; then
    log "Detected ${VRAM_GB}GB VRAM. Pulling medium models..."
    MODELS=("qwen2.5:7b" "phi4:14b" "nomic-embed-text")
else
    log "No dedicated GPU detected or low VRAM. Pulling CPU-optimized models..."
    MODELS=("qwen2.5:1.5b" "phi3:3.8b" "nomic-embed-text")
fi

for model in "${MODELS[@]}"; do
    log "Pulling $model..."
    ollama pull "$model" || warn "Failed to pull $model (may be unavailable)"
done

success "Models installed"

# =============================================================================
# STEP 4: Install Docker
# =============================================================================
log "Step 4/6: Installing Docker..."

if command -v docker &> /dev/null; then
    warn "Docker already installed. Skipping..."
else
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add user to docker group
    sudo usermod -aG docker "$USER"
    warn "You must log out and back in for Docker group changes to take effect"
    
    success "Docker installed"
fi

sudo systemctl enable docker
sudo systemctl start docker

# =============================================================================
# STEP 5: Install Open WebUI
# =============================================================================
log "Step 5/6: Installing Open WebUI (browser-based chat interface)..."

if docker ps | grep -q open-webui; then
    warn "Open WebUI already running. Skipping..."
else
    # Create volume directories
    sudo mkdir -p /opt/open-webui/data
    
    docker run -d \
        -p 3000:8080 \
        -v /opt/open-webui/data:/app/backend/data \
        -v ollama:/root/.ollama \
        --name open-webui \
        --restart always \
        ghcr.io/open-webui/open-webui:main
    
    success "Open WebUI installed at http://localhost:3000"
fi

# =============================================================================
# STEP 6: Configure Firewall
# =============================================================================
log "Step 6/6: Configuring firewall..."

if command -v ufw &> /dev/null; then
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 3000/tcp  # Open WebUI
    sudo ufw allow 11434/tcp # Ollama API (LAN only recommended)
    
    # Optional: Allow from specific subnet only
    # sudo ufw allow from 192.168.1.0/24 to any port 3000
    # sudo ufw allow from 192.168.1.0/24 to any port 11434
    
    sudo ufw --force enable
    success "Firewall configured"
else
    warn "UFW not installed. Install with: sudo apt install ufw"
fi

# =============================================================================
# Completion
# =============================================================================
echo
success "=========================================="
success "  Local AI Deployment Complete!"
success "=========================================="
echo
echo -e "Access your AI: ${GREEN}http://$(hostname -I | awk '{print $1}'):3000${NC}"
echo -e "Ollama API:      ${GREEN}http://$(hostname -I | awk '{print $1}'):11434${NC}"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Log out and back in (Docker group)"
echo "2. Visit http://localhost:3000 to create admin account"
echo "3. Test with: ollama run qwen2.5:7b"
echo "4. See harden-ubuntu.sh for security hardening"
echo
echo -e "${YELLOW}For remote admin access, install Tailscale:${NC}"
echo "   curl -fsSL https://tailscale.com/install.sh | sh"
echo "   sudo tailscale up"
