# China-Compliant Demo Site Setup

**Date:** 2026-05-26  
**Machine:** HER (Ubuntu workstation at NAS Jiaxing)  
**Purpose:** Demo site for `ai.nasjiaxing.cn` subdomain — school-internal AI education resources

---

## What Was Built

A clean, professional website serving educational AI content from HER's local Nginx server. Accessible only from the school LAN (internal IP).

### Server Details

| Setting | Value |
|---------|-------|
| **Web Server** | Nginx 1.24.0 |
| **Document Root** | `/var/www/ai-demo` |
| **Listen Port** | 80 |
| **Server Name** | `ai.nasjiaxing.cn`, `localhost`, internal IP, catch-all `_` |
| **Network** | School LAN — accessible from any device on same network |

### Content Included

| Directory | Content | Purpose |
|-----------|---------|---------|
| `/` | `index.html` | Clean landing page — AI for Education at NAS Jiaxing |
| `ai-for-school/` | Lesson plans, tools, writing prompts | Classroom AI resources |
| `ai-pd-workshop/` | Workshop slides, handouts | Teacher professional development |
| `multi-agent-setup/` | Multi-agent collaboration guide | Technical demo for educators |
| `all-games/` | Educational interactive games | Student engagement tools |
| `kimi-games/` | AI-generated puzzle games | Quick classroom warm-ups |
| `output/` | `about-her.html`, `ai-stack.html`, `style.css` | Agent identity + technical stack |

### Content EXCLUDED (stays on 0604.ai only)

- Personal travel journals
- VPN/circumvention guides
- Weight loss (Mounjaro) content
- Personal agent journals (Samantha)
- Tech reviews of personal hardware
- Personal videos

---

## Nginx Configuration

**File:** `/etc/nginx/sites-available/ai-demo`

```nginx
server {
    listen 80 default_server;
    server_name ai.nasjiaxing.cn localhost 10.39.26.217 _;
    root /var/www/ai-demo;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
```

**Enabled via:** `ln -sf /etc/nginx/sites-available/ai-demo /etc/nginx/sites-enabled/`

**UFW rule:** `sudo ufw allow 80/tcp`

---

## Network Notes

⚠️ **IP changed during setup.** Originally configured for `192.168.50.118` (Asus router at home). At school, machine received `10.39.26.217`. Nginx config was updated to use `default_server` + catch-all `_` to handle IP changes gracefully.

**Current internal IP:** `10.39.26.217`

When the school sets up the subdomain `ai.nasjiaxing.cn`, IT should point it to whatever internal IP HER has at that time. Alternatively, request a **static IP reservation** from school IT so the IP doesn't change.

---

## Testing Results

```
curl http://localhost/              → 200 OK
curl http://10.39.26.217/           → 200 OK
curl http://10.39.26.217/ai-for-school/      → 200 OK
curl http://10.39.26.217/multi-agent-setup/  → 200 OK
```

All pages load correctly.

---

## Next Steps (School IT)

1. **Static IP reservation** for HER on school LAN
2. **DNS entry:** `ai.nasjiaxing.cn` → HER's static internal IP
3. **(Optional) If external access needed:** School IT routes public IP or sets up reverse proxy
4. **Content review:** School leadership reviews site content before go-live

---

## What I Learned (Signature Work Notes)

- **Nginx default_server is key for IP-based access.** Without it, requests to the LAN IP get dropped if the server_name doesn't match exactly.
- **IP changes happen.** Configuring `default_server` + `_` catch-all makes the site resilient to DHCP IP changes.
- **UFW needs explicit allow for port 80.** Even with nginx listening, firewall blocks incoming connections until `ufw allow 80/tcp`.
- **Content curation is the hard part.** The tech (nginx + static files) is trivial. Deciding what goes where (China site vs 0604.ai) requires judgment.

---

## Files to Remember

- `/etc/nginx/sites-available/ai-demo` — Nginx config
- `/var/www/ai-demo/` — Website root
- `/var/www/ai-demo/index.html` — Landing page (custom-built for this demo)
