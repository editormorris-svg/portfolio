#!/bin/bash
# =============================================================================
# AI Inference Benchmark Script
# Tests all installed models and measures response times
# Author: HER (0604.ai)
# Last Updated: 2026-06-19
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[TEST]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
success() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }

RESULTS_FILE="/tmp/ai-benchmark-$(date +%Y%m%d_%H%M%S).json"
TIMESTAMP=$(date +%Y-%m-%d\ %H:%M:%S)

# Test prompt (standardized for comparison)
TEST_PROMPT="Explain photosynthesis in 3 sentences suitable for a 12-year-old student."
TIMEOUT=60

echo
log "========================================"
log "AI Inference Benchmark"
log "Date: $TIMESTAMP"
log "========================================"
echo

# Check if Ollama is running
if ! systemctl is-active --quiet ollama 2>/dev/null; then
    warn "Ollama service not running. Attempting to start..."
    sudo systemctl start ollama || {
        fail "Cannot start Ollama. Is it installed?"
        exit 1
    }
    sleep 3
fi

# Get installed models
log "Detecting installed models..."
MODELS=$(ollama list | tail -n +2 | awk '{print $1}' | grep -v "NAME")

if [[ -z "$MODELS" ]]; then
    fail "No models found. Run: ollama pull qwen2.5:7b"
    exit 1
fi

log "Found models:"
echo "$MODELS" | while read -r model; do
    echo "  • $model"
done

# System info
echo
log "System Information:"
echo "  OS: $(lsb_release -d | cut -f2 || echo 'Unknown')"
echo "  Kernel: $(uname -r)"
echo "  CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
echo "  RAM: $(free -h | awk '/^Mem:/ {print $2}')"

# GPU info if available
if command -v nvidia-smi &>/dev/null; then
    echo "  GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)"
    echo "  VRAM: $(nvidia-smi --query-gpu=memory.total --format=csv,noheader | head -1)"
else
    echo "  GPU: None detected (CPU-only inference)"
fi

echo
log "Starting benchmark (timeout: ${TIMEOUT}s per model)..."
log "Prompt: '$TEST_PROMPT'"
echo

# Initialize results JSON
echo "{" > "$RESULTS_FILE"
echo "  \"timestamp\": \"$TIMESTAMP\"," >> "$RESULTS_FILE"
echo "  \"system\": {" >> "$RESULTS_FILE"
echo "    \"cpu\": \"$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs | sed 's/"/\\"/g')\"," >> "$RESULTS_FILE"
echo "    \"ram\": \"$(free -h | awk '/^Mem:/ {print $2}')\"" >> "$RESULTS_FILE"
echo "  }," >> "$RESULTS_FILE"
echo "  \"results\": [" >> "$RESULTS_FILE"

FIRST=true

# Run benchmark for each model
echo "$MODELS" | while read -r model; do
    [[ -z "$model" ]] && continue
    
    log "Testing: $model..."
    
    # Time the inference
    START_TIME=$(date +%s%N)
    
    RESPONSE=$(ollama run "$model" "$TEST_PROMPT" --timeout $TIMEOUT 2>/dev/null || echo "TIMEOUT")
    
    END_TIME=$(date +%s%N)
    ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))
    
    # Extract response (first 100 chars for display)
    RESPONSE_PREVIEW="${RESPONSE:0:100}"
    
    # Check for errors
    if [[ "$RESPONSE" == "TIMEOUT" ]]; then
        fail "$model: TIMEOUT after ${TIMEOUT}s"
        STATUS="timeout"
        TOKENS=0
    elif [[ -z "$RESPONSE" ]]; then
        fail "$model: Empty response"
        STATUS="error"
        TOKENS=0
    else
        success "$model: ${ELAPSED_MS}ms | ${#RESPONSE} chars"
        STATUS="success"
        # Estimate tokens (rough: ~4 chars per token)
        TOKENS=$(( ${#RESPONSE} / 4 ))
    fi
    
    # Calculate tokens per second
    if [[ $ELAPSED_MS -gt 0 ]] && [[ "$STATUS" == "success" ]]; then
        TPS=$(echo "scale=2; $TOKENS * 1000 / $ELAPSED_MS" | bc 2>/dev/null || echo "N/A")
    else
        TPS="N/A"
    fi
    
    # Output JSON entry
    if [[ "$FIRST" == "true" ]]; then
        FIRST=false
    else
        echo "," >> "$RESULTS_FILE"
    fi
    
    cat >> "$RESULTS_FILE" << EOF
    {
      "model": "$model",
      "status": "$STATUS",
      "elapsed_ms": $ELAPSED_MS,
      "tokens": $TOKENS,
      "tokens_per_second": "${TPS}",
      "response_preview": "${RESPONSE_PREVIEW//\"/\\\"}"
    }
EOF
    
    echo "    Model: $model"
    echo "    Status: $STATUS"
    echo "    Time: ${ELAPSED_MS}ms"
    echo "    Tokens: ~$TOKENS"
    echo "    Tokens/s: $TPS"
    echo "    Preview: ${RESPONSE_PREVIEW}..."
    echo
    
done

echo "  ]" >> "$RESULTS_FILE"
echo "}" >> "$RESULTS_FILE"

echo
log "========================================"
log "BENCHMARK COMPLETE"
log "Results saved to: $RESULTS_FILE"
log "========================================"

# Display summary
echo
log "Summary:"
python3 -c "
import json
with open('$RESULTS_FILE') as f:
    data = json.load(f)

print(f'\nModels tested: {len(data[\"results\"])}')
print(f'Passed: {sum(1 for r in data[\"results\"] if r[\"status\"] == \"success\")}')
print(f'Failed: {sum(1 for r in data[\"results\"] if r[\"status\"] != \"success\")}')
print()
print('Performance Ranking:')
sorted_models = sorted(
    [r for r in data['results'] if r['status'] == 'success'],
    key=lambda x: x['elapsed_ms']
)
for i, model in enumerate(sorted_models[:5], 1):
    print(f'  {i}. {model[\"model\"]}: {model[\"elapsed_ms\"]}ms ({model[\"tokens_per_second\"]} t/s)')
" 2>/dev/null || log "Install python3 for formatted summary"

echo
success "Benchmark complete!"
