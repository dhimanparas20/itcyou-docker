# itcyou - Lightweight Tunnel Client for Docker

**Expose your localhost to the internet in seconds** 🚀

[![Docker Pulls](https://img.shields.io/docker/pulls/dhimanparas20/itcyou)](https://hub.docker.com/r/dhimanparas20/itcyou)
[![Docker Image Size](https://img.shields.io/docker/image-size/dhimanparas20/itcyou/latest)](https://hub.docker.com/r/dhimanparas20/itcyou)
[![Alpine Linux](https://img.shields.io/badge/alpine-3.21-blue?logo=alpine-linux)](https://alpinelinux.org/)

## What is itcyou?

[itcyou](https://it.cyou/) is a modern tunneling service that creates secure HTTPS URLs for your local development servers. Think ngrok, but cleaner and faster.

This Docker image provides a **~20MB** lightweight Alpine-based container to expose your local services to the internet instantly.

## 🚀 Quick Start

### Docker Run (30 seconds)
```bash
# Random subdomain
docker run -d --rm --network host \
  -e ITCYOU_PORT=3000 \
  dhimanparas20/itcyou:latest

# Custom subdomain
docker run -d --rm --network host \
  -e ITCYOU_PORT=3000 \
  -e ITCYOU_SUBDOMAIN=myapp \
  dhimanparas20/itcyou:latest

# With authentication (reserved subdomain)
docker run -d --rm --network host \
  -e ITCYOU_PORT=3000 \
  -e ITCYOU_SUBDOMAIN=myreservedname \
  -e ITCYOU_TOKEN=itc_yourapikey \
  dhimanparas20/itcyou:latest
```

### Docker Compose (Linux)
```yaml
services:
  itcyou:
    image: dhimanparas20/itcyou:latest
    container_name: itcyou-tunnel
    restart: unless-stopped
    network_mode: host
    environment:
      ITCYOU_PORT: "3000"
      ITCYOU_SUBDOMAIN: "myapp"
      # ITCYOU_TOKEN: "itc_yourapikey"
```

### Docker Compose (Windows/macOS)
```yaml
services:
  itcyou:
    image: dhimanparas20/itcyou:latest
    container_name: itcyou-tunnel
    restart: unless-stopped
    environment:
      ITCYOU_PORT: "3000"
      ITCYOU_SUBDOMAIN: "myapp"
      ITCYOU_TARGET_HOST: "host.docker.internal"  # Required for Windows/macOS
      # ITCYOU_TOKEN: "itc_yourapikey"
```

## 📋 Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `ITCYOU_PORT` | ✅ Yes | `3000` | Local port to expose |
| `ITCYOU_TARGET_HOST` | ❌ No | `localhost` | Target host (`host.docker.internal` for Windows/macOS) |
| `ITCYOU_SUBDOMAIN` | ❌ No | random | Preferred subdomain |
| `ITCYOU_TOKEN` | ❌ No | — | API key for reserved subdomains |
| `ITCYOU_HOST` | ❌ No | `it.cyou` | Custom server host |
| `ITCYOU_SERVER_PORT` | ❌ No | `4443` | Custom server port |
| `ITCYOU_INSECURE` | ❌ No | — | Skip TLS (dev only) |

## 💡 Common Use Cases

- **Web Development**: Share local dev servers with your team
- **Webhook Testing**: Test Stripe, GitHub, or other webhooks locally
- **Mobile Testing**: Preview apps on real devices
- **Database Sharing**: Expose PostgreSQL/MySQL for remote access
- **IoT Development**: Secure tunnels for device communication

## 🐧 Requirements

- **Linux only** — Requires `--network host` which doesn't work on macOS/Windows Docker Desktop
- Docker 20.10+
- Your target service must be running before starting the tunnel

## 🔗 Links

- 📦 **Docker Hub**: https://hub.docker.com/r/dhimanparas20/itcyou
- 💻 **GitHub**: https://github.com/dhimanparas20/itcyou-docker
- 🌐 **Official Site**: https://it.cyou/

## 📝 License

MIT License - See GitHub repository for details.

---

**Made with ❤️ by [Paras Dhiman](https://github.com/dhimanparas20)**
