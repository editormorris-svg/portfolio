# Secure Local AI Deployment Guide

**For: International Schools in China**  
**Version: 1.0**  
**Last Updated: 2026-06-19**  
**Built by HER | Reviewed by Kimi | 0604.ai**

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [The Problem: Cloud AI Risks](#the-problem-cloud-ai-risks)
3. [The Solution: Local Deployment](#the-solution-local-deployment)
4. [Use Cases by Role](#use-cases-by-role)
5. [Hardware Builds](#hardware-builds)
6. [Implementation Roadmap](#implementation-roadmap)
7. [Technical Setup](#technical-setup)
8. [Compliance & Safeguarding](#compliance--safeguarding)
9. [Sample Scripts](#sample-scripts)
10. [Troubleshooting](#troubleshooting)
11. [Further Resources](#further-resources)

---

## Executive Summary

This guide walks international schools in China through deploying a **secure, private AI system** on their own hardware. All data stays on-premises. No student information ever leaves the school network. The system runs 100% offline for AI inference — internet is only needed for software updates.

### Key Benefits

- **Zero data exposure**: Student records, assessment data, and pastoral notes never leave the building
- **Fixed costs**: One-time hardware purchase, no per-seat subscriptions
- **Full compliance**: Automatic PIPL and GDPR compliance — data stays in China
- **Complete audit trail**: Every AI query is logged with user identification
- **No latency**: Sub-second response times, works during network outages

### What This Guide Covers

- Three hardware configurations (¥3,500–¥14,050)
- 4-week implementation timeline
- Step-by-step technical setup
- Downloadable automation scripts
- Compliance checklist and audit templates

---

## The Problem: Cloud AI Risks

### Real-World Scenarios

| Scenario | Risk | Impact |
|----------|------|--------|
| Teacher uploads student writing sample to ChatGPT for feedback | Student work processed on US servers, potentially retained for training | PIPL violation; student data in foreign training dataset |
| VP pastes behavioral incident report into cloud AI | Child protection details leave jurisdiction | Safeguarding breach; potential regulatory action |
| Admin uploads class list to generate seating chart | PII exposed to third-party provider | Data processing without consent; privacy violation |
| Exam coordinator uses cloud AI to draft questions | Assessment content leaked | Competitive intelligence loss; academic integrity risk |

### The CLOUD Act Problem

US-based AI companies are subject to the **CLOUD Act**, which allows US law enforcement to access data stored on US servers regardless of where the data originated. For schools in China, this creates an irreconcilable conflict with **PIPL** (Personal Information Protection Law), which requires personal data to remain within China.

### Hidden Costs

| Cloud AI Cost | Year 1 | Year 3 | Notes |
|---------------|--------|--------|-------|
| ChatGPT Plus (20 staff) | ¥3,000 | ¥9,000 | $20/month × 20 users |
| API usage (moderate) | ¥2,000 | ¥6,000 | Grows with adoption |
| Enterprise AI tool | ¥8,000 | ¥24,000 | Per-seat licensing |
| **Total Cloud** | **¥13,000** | **¥39,000** | And climbing |
| **Local AI (Standard)** | **¥7,500** | **¥7,500** | One-time cost |

**3-year savings: ¥31,500** — enough to buy a second Standard build for redundancy.

---

## The Solution: Local Deployment

### What Is Local AI?

Local AI deployment means running open-source AI models on a **physical server inside your school**. The server:

- Runs on your LAN (no internet needed for AI tasks)
- Processes all data locally
- Stores nothing on external servers
- Provides complete audit logs
- Can be administered remotely via VPN (Tailscale)

### Architecture Overview

```
┌─────────────────────────────────────────────┐
│              SCHOOL LAN                      │
│  Teacher ──→ AI Server ──→ NAS/Backups     │
│  Staff    │  (Ubuntu)    │                   │
│  Student  │  • Ollama    │  Tailscale VPN    │
│           │  • ComfyUI   │  ←── Remote Admin │
│           │  • Web UI    │                   │
│  Internet │              │                   │
│  (WAN)   │  ← Updates only                │
└─────────────────────────────────────────────┘
```

### Software Stack

| Component | Purpose | Open Source |
|-----------|---------|-------------|
| **Ollama** | Model management and inference | Yes (MIT) |
| **Open WebUI** | Browser-based chat interface | Yes (MIT) |
| **Qwen/Llama/Mistral** | Large language models | Yes (Apache 2.0) |
| **ComfyUI** | Image generation workflow | Yes (GPL) |
| **Tailscale** | Secure remote access (optional) | Yes (BSD) |

---

## Use Cases by Role

### Principal & Senior Leadership
- **Strategic planning**: Generate SWOT analysis, draft strategic documents
- **Policy drafting**: Create/update school policies with AI assistance
- **Risk assessment**: Generate risk matrices, compliance checklists
- **Report writing**: Board reports, inspection preparation

### Vice Principal & Safeguarding
- **Incident documentation**: Draft professional incident reports
- **Investigation summaries**: Summarize complex multi-stakeholder situations
- **Policy review**: Check safeguarding policies against best practices
- **Communication**: Draft sensitive communications to parents

### Pastoral & EAL/SEN Teams
- **IEP drafting**: Generate individualized education plan templates
- **Differentiated materials**: Adapt content for different learning needs
- **Communication**: Translate between English and Chinese for parents
- **Progress reports**: Draft detailed pastoral progress notes

### Teachers (All Subjects)
- **Lesson planning**: Generate complete lesson plans with differentiation
- **Quiz creation**: Create formative assessments with answer keys
- **Report card comments**: Generate personalized, professional comments
- **Rubric design**: Create detailed assessment rubrics
- **Resource adaptation**: Adapt textbook content for different levels

### MAC & Art Departments
- **Image generation**: Create custom illustrations for worksheets
- **Presentation design**: Generate slide decks from outlines
- **Video scripts**: Draft scripts for instructional videos
- **Marketing materials**: Design flyers, posters, social media content

### Admin & IT
- **Newsletter writing**: Draft professional school newsletters
- **Website content**: Generate page copy, update descriptions
- **Policy documents**: Draft HR policies, IT acceptable use policies
- **Data analysis**: Summarize survey results, analyze usage data

### Finance & HR
- **Budget analysis**: Identify trends, generate variance reports
- **Job descriptions**: Draft professional job descriptions
- **Interview questions**: Generate role-specific interview questions
- **Contract review**: Check employment contracts for compliance

### Science & Math
- **Problem generation**: Create unlimited practice problems
- **Lab report templates**: Generate structured lab report templates
- **Data analysis**: Process experiment data, identify patterns
- **Explanation drafting**: Write clear explanations of complex concepts

### Language Departments
- **Translation**: Translate between English and Chinese
- **Conversation practice**: Generate dialogue practice scenarios
- **Cultural materials**: Create materials about English-speaking cultures
- **Grammar exercises**: Generate targeted grammar practice

---

## Hardware Builds

### Entry Build: ¥3,500

| Component | Spec | Price (¥) |
|-----------|------|-----------|
| CPU | Intel N95 (4-core) | Included |
| RAM | 32GB DDR4 | 400 |
| Storage | 500GB NVMe SSD | 300 |
| GPU | Integrated | — |
| Case | Mini ITX | 200 |
| PSU | 150W | 100 |
| **Total** | | **~¥3,500** |

**Best for:** Small departments, pilot projects, testing the concept  
**Limitations:** CPU-only inference (slower), small models only (3B-7B parameters), 1-5 concurrent users

### Standard Build: ¥7,500 ⭐ RECOMMENDED

| Component | Spec | Price (¥) |
|-----------|------|-----------|
| CPU | AMD Ryzen 7 7800X3D | 2,500 |
| RAM | 64GB DDR5 | 800 |
| Storage | 1TB NVMe SSD | 500 |
| GPU | Tesla A2 16GB | 2,000 |
| Case | Mid Tower | 300 |
| PSU | 650W 80+ Gold | 400 |
| **Total** | | **~¥7,500** |

**Best for:** Whole school deployment, all departments  
**Capabilities:** 7B-13B models, image generation, 10-20 concurrent users  
**Example:** The HIM server at NAS Jiaxing uses this build

### Enterprise Build: ¥14,050

| Component | Spec | Price (¥) |
|-----------|------|-----------|
| CPU | AMD Ryzen 9 7950X3D | 4,500 |
| RAM | 96GB DDR5 | 1,500 |
| Storage | 2TB NVMe + 8TB HDD | 800 + 1,000 |
| GPU | 7048GR (dual slot) | 4,000 |
| Case | Full Tower | 400 |
| PSU | 850W 80+ Platinum | 850 |
| **Total** | | **~¥14,050** |

**Best for:** Multi-campus, heavy workloads, future-proofing  
**Capabilities:** 13B-70B models, high-res image generation, 50+ users  
**Example:** HER (this machine) is the Enterprise build

### Where to Buy in China

- **Tmall/JD.com**: Search for "AI推理服务器" (AI inference server)
- **Tesla A2**: Available from NVIDIA partners, ~¥2,000
- **7048GR**: Available from server suppliers, ~¥4,000
- **Consumer GPU alternative**: RTX 4060 Ti 16GB (~¥3,000) works for smaller models

---

## Implementation Roadmap

### Week 1: Planning & Procurement

**Day 1-2: Requirements Gathering**
- [ ] Identify pilot department (recommend IT or Admin first)
- [ ] Define use cases and success criteria
- [ ] Determine required models (Chinese/English bilingual?)
- [ ] Assign project owner

**Day 3-4: Hardware Procurement**
- [ ] Finalize build configuration
- [ ] Place orders for components
- [ ] Prepare network port and power
- [ ] Designate server location (ventilated, secure)

**Day 5: Network Preparation**
- [ ] Reserve static IP on school LAN
- [ ] Configure VLAN if desired (isolated AI network)
- [ ] Test network connectivity
- [ ] Document network settings

### Week 2: Assembly & OS Installation

**Day 1: Hardware Assembly**
- [ ] Assemble server components
- [ ] Test POST and BIOS
- [ ] Configure BIOS (enable virtualization, set boot order)
- [ ] Verify all hardware detected

**Day 2: Ubuntu Installation**
- [ ] Download Ubuntu 24.04 LTS ISO
- [ ] Create bootable USB
- [ ] Install Ubuntu with LVM for easy disk expansion
- [ ] Create admin user (not root!)

**Day 3: Network Configuration**
- [ ] Set static IP address
- [ ] Configure DNS
- [ ] Test SSH access from admin workstation
- [ ] Set up SSH key authentication

**Day 4: Basic Security**
- [ ] Run `harden-ubuntu.sh` (see scripts/)
- [ ] Configure firewall (UFW)
- [ ] Set up fail2ban
- [ ] Enable automatic security updates

**Day 5: Remote Access**
- [ ] Install Tailscale for remote admin
- [ ] Test remote access from home
- [ ] Document Tailscale IP
- [ ] Verify remote SSH works

### Week 3: AI Stack Installation

**Day 1: Install Ollama**
- [ ] Run `install-ollama.sh` (see scripts/)
- [ ] Verify Ollama service running
- [ ] Test basic inference: `ollama run qwen2.5:7b`

**Day 2: Pull Models**
- [ ] Pull recommended models (see below)
- [ ] Test each model with sample prompts
- [ ] Document model performance on your hardware
- [ ] Remove unused models to save space

**Day 3: Install Web Interface**
- [ ] Install Docker and Open WebUI
- [ ] Create admin account
- [ ] Test from teacher workstation
- [ ] Configure basic settings

**Day 4: Install ComfyUI (Optional)**
- [ ] Install ComfyUI for image generation
- [ ] Download recommended checkpoints
- [ ] Test image generation
- [ ] Document workflow for art department

**Day 5: Testing & Tuning**
- [ ] Run `test-inference.sh` benchmark
- [ ] Identify optimal models for your use cases
- [ ] Tune performance settings
- [ ] Document known issues and workarounds

### Week 4: User Training & Go-Live

**Day 1: Staff Training Session**
- [ ] Present this workshop (see presentation)
- [ ] Demonstrate key features
- [ ] Practice with sample prompts
- [ ] Distribute user guides

**Day 2: Department Pilot**
- [ ] Onboard pilot department
- [ ] Create user accounts
- [ ] Monitor usage and gather feedback
- [ ] Address any issues

**Day 3-4: Documentation**
- [ ] Create internal wiki page
- [ ] Document common prompts for each role
- [ ] Write troubleshooting guide
- [ ] Set up feedback channel

**Day 5: Monitoring & Review**
- [ ] Review audit logs
- [ ] Check system resources
- [ ] Gather feedback from pilot users
- [ ] Plan expansion to other departments

---

## Technical Setup

### Quick Start (6 Commands)

```bash
# Step 1: Update system
sudo apt update && sudo apt upgrade -y

# Step 2: Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Step 3: Pull a model
ollama pull qwen2.5:7b

# Step 4: Test it
ollama run qwen2.5:7b "Write a 5-question quiz about photosynthesis"

# Step 5: Install Docker
sudo apt install docker.io docker-compose -y
sudo systemctl enable docker

# Step 6: Run Open WebUI
docker run -d -p 3000:8080 \
  -v ollama:/root/.ollama \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

### Recommended Models for Schools

| Model | Size | Best For | Language |
|-------|------|----------|----------|
| **Qwen 2.5** | 7B | General use, Chinese/English | Bilingual |
| **Llama 3.1** | 8B | English content, reasoning | English |
| **Mistral** | 7B | Fast inference, summaries | English |
| **Phi-4** | 14B | High-quality reasoning | English |
| **nomic-embed** | Small | Document search, embeddings | Multilingual |

**Install all:**
```bash
ollama pull qwen2.5:7b
ollama pull llama3.1:8b
ollama pull mistral:7b
ollama pull nomic-embed-text
```

### Model Selection Guide

- **Chinese/English bilingual**: Qwen 2.5 series (best for China schools)
- **Pure English, best quality**: Llama 3.1 or Phi-4
- **Fastest responses**: Mistral or Qwen 2.5 1.5B (for older hardware)
- **Document search**: nomic-embed-text for RAG (Retrieval Augmented Generation)

---

## Compliance & Safeguarding

### PIPL Compliance Checklist

- [ ] Data stored on physical hardware in China
- [ ] Explicit consent obtained for AI processing
- [ ] Data minimization: only necessary data processed
- [ ] Retention period defined (e.g., 30 days for query logs)
- [ ] Deletion procedure documented
- [ ] Data processing agreement on file
- [ ] DPIA (Data Protection Impact Assessment) completed
- [ ] Staff training on data protection completed
- [ ] Incident response plan documented
- [ ] Regular audits scheduled (quarterly)

### GDPR Compliance Checklist

- [ ] Lawful basis for processing documented
- [ ] Right to erasure procedure in place
- [ ] Data portability available (export logs)
- [ ] Processing records maintained
- [ ] DPO contact information published
- [ ] Breach notification procedure (72 hours)
- [ ] Cross-border transfer safeguards (N/A for local)

### Sample Audit Log Entry

```
# /var/log/ai-audit/2026-06-19.log
[2026-06-19 09:14:23] USER: wmorris  ROLE: teacher
  QUERY: "Generate 5 reading comprehension questions for Y7"
  MODEL: qwen2.5:7b  TOKENS: 234
  STATUS: ✓ ALLOWED  CATEGORY: lesson-planning

[2026-06-19 09:22:15] USER: admin    ROLE: vp
  QUERY: "Summarize pastoral incident report #2026-044"
  MODEL: qwen2.5:7b  TOKENS: 1,892
  STATUS: ✓ ALLOWED  CATEGORY: pastoral
  NOTE: SEN flag detected — auto-encrypted

[2026-06-19 10:05:42] USER: guest    ROLE: visitor
  QUERY: "Tell me about student Zhang Wei"
  STATUS: ✗ BLOCKED  REASON: unauthorized_PII_query
  ALERT: email sent to safeguarding@school.edu
```

### Safeguarding Best Practices

1. **No anonymous access**: Every user must authenticate
2. **Role-based permissions**: Teachers cannot access pastoral data
3. **PII detection**: Auto-block queries containing student names
4. **Query logging**: Every prompt logged with user ID and timestamp
5. **Regular review**: Weekly audit of flagged queries
6. **Encryption**: Sensitive categories (pastoral, SEN) auto-encrypted
7. **Retention**: Delete logs after 90 days (configurable)

---

## Sample Scripts

All scripts are available in the `scripts/` directory of this presentation:

### 1. install-ollama.sh
Full Ubuntu setup: Ollama, Docker, Open WebUI, model pulls, auto-start. See scripts/install-ollama.sh.

### 2. harden-ubuntu.sh
SSH hardening, firewall rules, fail2ban, automatic security updates. See scripts/harden-ubuntu.sh.

### 3. backup-script.sh
Daily model backups, weekly system snapshots, retention policy. See scripts/backup-script.sh.

### 4. test-inference.sh
Benchmark script: tests all models, measures response time, logs results. See scripts/test-inference.sh.

### Usage

```bash
# Make executable
chmod +x scripts/*.sh

# Run installation
sudo ./scripts/install-ollama.sh

# Harden security (run as root)
sudo ./scripts/harden-ubuntu.sh

# Set up daily backup (add to crontab)
crontab -e
# Add: 0 2 * * * /path/to/scripts/backup-script.sh

# Run benchmark
./scripts/test-inference.sh
```

---

## Troubleshooting

### Problem: Ollama won't start
```bash
# Check service status
sudo systemctl status ollama

# Check logs
sudo journalctl -u ollama -n 50

# Common fix: reinstall
sudo systemctl stop ollama
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl start ollama
```

### Problem: Models are slow
```bash
# Check GPU usage
nvidia-smi

# Check CPU usage
htop

# Reduce model size
ollama pull qwen2.5:1.5b  # Smaller, faster

# Or use CPU-only mode (if no GPU)
OLLAMA_NO_CUDA=1 ollama serve
```

### Problem: Open WebUI won't connect
```bash
# Check if container is running
docker ps | grep open-webui

# Restart container
docker restart open-webui

# Check logs
docker logs open-webui --tail 50

# Reset container (data preserved in volume)
docker rm -f open-webui
docker run -d -p 3000:8080 \
  -v ollama:/root/.ollama \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

### Problem: SSH key authentication fails
```bash
# Check authorized_keys format
cat ~/.ssh/authorized_keys | cat -A
# Should show one key per line, no ^M (CRLF)

# Fix PAM issue (Ubuntu-specific)
grep pam_sss /etc/pam.d/common-account
# If found, comment it out:
sudo sed -i 's/^account.*pam_sss.so/#&/' /etc/pam.d/common-account
sudo systemctl restart sshd
```

### Problem: Out of disk space
```bash
# Check usage
df -h

# Find large files
sudo du -sh /usr/share/ollama/.ollama/models/*

# Remove unused models
ollama rm model-name

# Clean up Docker
docker system prune -a
```

---

## Further Resources

### Official Documentation
- [Ollama Documentation](https://github.com/ollama/ollama)
- [Open WebUI Documentation](https://github.com/open-webui/open-webui)
- [Qwen Model Documentation](https://github.com/QwenLM/Qwen)
- [ComfyUI Documentation](https://github.com/comfyanonymous/ComfyUI)

### 0604.ai Resources
- [AI Fleet Overview](https://0604.ai/ai-fleet.html) — See HER and HIM in action
- [AI Tools for Educators](https://0604.ai/ai-pd-workshop/) — First PD workshop
- [Multi-Agent Setup](https://0604.ai/multi-agent-setup/) — Advanced configuration

### Community
- [NAS Jiaxing Tech Lab](https://0604.ai/tech-lab.html) — Internal resources
- [Contact: 1@0604.ai](mailto:1@0604.ai) — Questions and support

### Hardware Suppliers (China)
- Search Tmall: "AI推理服务器" or "GPU服务器"
- Tesla A2: Contact NVIDIA authorized resellers
- For questions about specific builds: contact@0604.ai

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-06-19 | Initial release |

---

*Built by HER (AMD Ryzen 9 7950X3D, 96GB RAM, RX 7900 XTX)*  
*Reviewed by Kimi (Cloud instance, Singapore)*  
*Presented by William Morris | 0604.ai*
