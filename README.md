# 🚀 ITCYOU DOCKER

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-dhimanparas20%2Fitcyou-blue?logo=docker)](https://hub.docker.com/r/dhimanparas20/itcyou)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Alpine](https://img.shields.io/badge/alpine-3.21-0D597F?logo=alpine-linux)](https://alpinelinux.org/)
[![GitHub](https://img.shields.io/badge/GitHub-dhimanparas20-black?logo=github)](https://github.com/dhimanparas20)

> **⚡ The fastest way to expose your localhost to the internet**

A lightweight, production-ready Docker image for [**itcyou**](https://it.cyou/) — the modern ngrok alternative that creates secure tunnels from the public internet to your local services.

---

## 🎯 What is itcyou?

[**it.cyou**](https://it.cyou/) is a tunneling service that creates secure HTTPS URLs for your local development servers. Think ngrok, but cleaner, faster, and more developer-friendly.

### Use Cases
- 🌐 **Share local dev servers** with teammates or clients
- 📱 **Test webhooks** from external services (Stripe, GitHub, etc.)
- 🧪 **Preview apps** on mobile devices before deploying
- 🔒 **Secure tunnels** for IoT devices and internal tools
- 🎮 **Game server** sharing for LAN parties

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🪶 **Ultra-Lightweight** | ~15-25 MB final image size |
| 🐧 **Linux Native** | Optimized for Linux hosts with `network_mode: host` |
| 🔧 **Zero Config** | Works out of the box with sensible defaults |
| 🔐 **Secure by Default** | TLS encryption for all tunnels |
| 🎯 **Custom Subdomains** | Reserve your own subdomain with auth token |
| 🔄 **Auto-Restart** | Docker Compose handles crashes gracefully |
| 📊 **Multi-Tunnel Ready** | Run multiple tunnels simultaneously |

---

## 🚦 Quick Start (30 Seconds)

### Option 1: Docker Run (Random Subdomain)
```bash
docker run -d --rm \
  --name itcyou-tunnel \
  --network host \
  -e ITCYOU_PORT=3000 \
  dhimanparas20/itcyou:latest
```

### Option 2: Docker Run (Custom Subdomain)
```bash
docker run -d --rm \
  --name itcyou-tunnel \
  --network host \
  -e ITCYOU_PORT=3000 \
  -e ITCYOU_SUBDOMAIN=myawesomeapp \
  dhimanparas20/itcyou:latest
```

### Option 3: Docker Run (With Authentication)
```bash
docker run -d --rm \
  --name itcyou-tunnel \
  --network host \
  -e ITCYOU_PORT=3000 \
  -e ITCYOU_SUBDOMAIN=myreservedname \
  -e ITCYOU_TOKEN=itc_yourapikey \
  dhimanparas20/itcyou:latest
```

---

## 🐳 Docker Compose (Recommended)

### Single Tunnel Setup

Create a `docker-compose.yml`:

```yaml
services:
  itcyou:
    image: dhimanparas20/itcyou:latest
    container_name: itcyou-tunnel
    restart: unless-stopped
    network_mode: host
    environment:
      ITCYOU_PORT: "3000"                      # Required: Your local service port
      ITCYOU_SUBDOMAIN: "myapp"                # Optional: Custom subdomain
      # ITCYOU_TOKEN: "itc_yourapikey"         # Optional: Auth token for reserved subdomains
      # ITCYOU_HOST: "it.cyou"                 # Optional: Custom server host
      # ITCYOU_SERVER_PORT: "4443"             # Optional: Custom server port
      # ITCYOU_INSECURE: "true"                # Optional: Dev only — skip TLS verify
```

Run it:
```bash
# Start the tunnel
docker compose up -d

# View logs and get your public URL
docker logs -f itcyou-tunnel

# Stop the tunnel
docker compose down
```

### Multiple Tunnels Setup

```yaml
services:
  # Frontend tunnel
  frontend:
    image: dhimanparas20/itcyou:latest
    container_name: itcyou-frontend
    restart: unless-stopped
    network_mode: host
    environment:
      ITCYOU_PORT: "5173"
      ITCYOU_SUBDOMAIN: "frontend"
      ITCYOU_TOKEN: "itc_yourapikey"

  # API tunnel
  api:
    image: dhimanparas20/itcyou:latest
    container_name: itcyou-api
    restart: unless-stopped
    network_mode: host
    environment:
      ITCYOU_PORT: "4000"
      ITCYOU_SUBDOMAIN: "api"
      ITCYOU_TOKEN: "itc_yourapikey"

  # Database tunnel (TCP)
  postgres:
    image: dhimanparas20/itcyou:latest
    container_name: itcyou-postgres
    restart: unless-stopped
    network_mode: host
    environment:
      ITCYOU_PORT: "5432"
      ITCYOU_SUBDOMAIN: "pgdb"
      ITCYOU_TOKEN: "itc_yourapikey"
```

---

## 📋 Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `ITCYOU_PORT` | ✅ **Yes** | `3000` | The local port your service is running on |
| `ITCYOU_SUBDOMAIN` | ❌ No | (random) | Your preferred subdomain → `https://yourname.it.cyou` |
| `ITCYOU_TOKEN` | ❌ No | — | API key from [it.cyou](https://it.cyou/) for reserved subdomains |
| `ITCYOU_HOST` | ❌ No | `it.cyou` | Custom tunnel server hostname |
| `ITCYOU_SERVER_PORT` | ❌ No | `4443` | Custom tunnel server port |
| `ITCYOU_INSECURE` | ❌ No | — | Set to `"true"` to skip TLS verification (⚠️ **dev only!**) |

---

## 🎮 Real-World Examples

### Next.js / React App
```bash
docker run -d --rm --network host \
  -e ITCYOU_PORT=3000 \
  -e ITCYOU_SUBDOMAIN=my-next-app \
  dhimanparas20/itcyou:latest
```

### Vite Development Server
```bash
docker run -d --rm --network host \
  -e ITCYOU_PORT=5173 \
  -e ITCYOU_SUBDOMAIN=my-vite-app \
  dhimanparas20/itcyou:latest
```

### FastAPI / Flask Backend
```bash
docker run -d --rm --network host \
  -e ITCYOU_PORT=8000 \
  -e ITCYOU_SUBDOMAIN=my-api \
  dhimanparas20/itcyou:latest
```

### PostgreSQL Database (TCP Tunnel)
```bash
docker run -d --rm --network host \
  -e ITCYOU_PORT=5432 \
  -e ITCYOU_SUBDOMAIN=my-postgres \
  dhimanparas20/itcyou:latest
```

### Node.js Express Server
```bash
docker run -d --rm --network host \
  -e ITCYOU_PORT=8080 \
  -e ITCYOU_SUBDOMAIN=express-demo \
  dhimanparas20/itcyou:latest
```

---

## 🔨 Build from Source

### Prerequisites
- Docker 20.10+
- Docker Compose v2+
- Linux host (Ubuntu, Debian, CentOS, Arch, etc.)

### Build Steps
```bash
# Clone the repository
git clone https://github.com/dhimanparas20/itcyou-docker.git
cd itcyou-docker

# Build the Docker image
docker build -t dhimanparas20/itcyou:latest .

# Test locally (make sure something is running on port 3000)
docker run --rm --network host \
  -e ITCYOU_PORT=3000 \
  -e ITCYOU_SUBDOMAIN=test \
  dhimanparas20/itcyou:latest

# Push to Docker Hub
docker login
docker push dhimanparas20/itcyou:latest
```

---

## 📦 How to Pull from Docker Hub

### Latest Tag
```bash
docker pull dhimanparas20/itcyou:latest
```

### Specific Version (when available)
```bash
docker pull dhimanparas20/itcyou:v1.0.0
```

### Verify the Image
```bash
docker images | grep itcyou
```

---

## 🛠️ Project Structure

```
itcyou-docker/
├── Dockerfile              # Multi-stage Alpine-based build
├── docker-compose.yml      # Compose configuration examples
├── entrypoint.sh           # Dynamic command builder
└── README.md               # This file
```

---

## ⚠️ Requirements & Limitations

### ✅ Works On
- **Linux** (Ubuntu, Debian, CentOS, Arch, etc.)
- **Docker Desktop on Linux** (with limitations)
- **Cloud VMs** (AWS EC2, DigitalOcean Droplets, etc.)
- **Raspberry Pi** and ARM devices

### ❌ Does NOT Work On
- **macOS** (Docker Desktop) — `network_mode: host` is not supported
- **Windows** (Docker Desktop) — `network_mode: host` is not supported
- **WSL2** — May work with caveats

### Why Linux Only?
The `network_mode: host` option is required because the itcyou binary needs direct access to `localhost` to reach your services. On Linux, this makes the container share the host's network stack — no NAT, no bridge, no port mapping needed.

**Note:** macOS and Windows Docker Desktop run Docker inside a VM, so `host` networking doesn't work as expected. For those platforms, consider using the native itcyou binary instead.

---

## 🔍 Troubleshooting

### Container won't start
```bash
# Check if your service is actually running on the specified port
curl http://localhost:3000

# View container logs
docker logs itcyou-tunnel
```

### Subdomain already taken
```bash
# Try a different subdomain or authenticate with a token
docker run -d --rm --network host \
  -e ITCYOU_PORT=3000 \
  -e ITCYOU_SUBDOMAIN=unique-name-123 \
  -e ITCYOU_TOKEN=itc_yourapikey \
  dhimanparas20/itcyou:latest
```

### Connection refused errors
```bash
# Ensure your service is running BEFORE starting the tunnel
# The tunnel expects the target port to be available immediately
```

### "network_mode: host" not working
```bash
# Verify you're on Linux
cat /etc/os-release

# Check Docker version
docker --version

# Try with explicit network host flag
docker run -d --rm --network host dhimanparas20/itcyou:latest
```

---

## 📝 Docker Compose Cheatsheet

```bash
# Start services
docker compose up -d

# Start with build
docker compose up -d --build

# View logs
docker compose logs -f

# View logs for specific service
docker compose logs -f itcyou

# Stop services
docker compose down

# Restart services
docker compose restart

# Scale multiple instances
docker compose up -d --scale itcyou=3
```

---

## 🔗 Useful Links

- 🌐 **Official Website**: [https://it.cyou/](https://it.cyou/)
- 📦 **Docker Hub**: [https://hub.docker.com/r/dhimanparas20/itcyou](https://hub.docker.com/r/dhimanparas20/itcyou)
- 💻 **GitHub Repo**: [https://github.com/dhimanparas20/itcyou-docker](https://github.com/dhimanparas20/itcyou-docker)
- 🐦 **Twitter/X**: Follow [@itcyou](https://twitter.com/itcyou) for updates

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Built with ❤️ by [dhimanparas20](https://github.com/dhimanparas20)
- Powered by [it.cyou](https://it.cyou/) tunneling service
- Alpine Linux base image for minimal footprint

---

<div align="center">

**⭐ Star this repo if you find it useful! ⭐**

Made with 🔥 by [Paras Dhiman](https://github.com/dhimanparas20)

</div>
