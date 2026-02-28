#### 📁 Project Structure

```
itcyou-docker/
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
└── README.md
```

---

#### 🐳 Dockerfile

```dockerfile
# =============================================================================
#  itcyou — Lightweight Docker Image
# =============================================================================
#
#  🌐 Official Site:  https://it.cyou/
#  📦 What it does:   Exposes your localhost services to the internet via
#                     secure tunnels (like ngrok, but cleaner).
#
#  🏗️  Build:
#       docker build -t yourdockerhubuser/itcyou:latest .
#
#  🚀 Quick One-Liner (No Compose):
#       docker run -d --rm \
#         --name itcyou-tunnel \
#         --network host \
#         -e ITCYOU_PORT=3000 \
#         -e ITCYOU_SUBDOMAIN=myapp \
#         yourdockerhubuser/itcyou:latest
#
#  🚀 Quick One-Liner with Auth Token:
#       docker run -d --rm \
#         --name itcyou-tunnel \
#         --network host \
#         -e ITCYOU_PORT=3000 \
#         -e ITCYOU_SUBDOMAIN=myapp \
#         -e ITCYOU_TOKEN=itc_yourapikey \
#         yourdockerhubuser/itcyou:latest
#
#  🚀 Random Subdomain (simplest possible):
#       docker run -d --rm \
#         --name itcyou-tunnel \
#         --network host \
#         -e ITCYOU_PORT=3000 \
#         yourdockerhubuser/itcyou:latest
#
#  🚀 Multiple Tunnels (run multiple containers):
#       docker run -d --network host -e ITCYOU_PORT=3000 -e ITCYOU_SUBDOMAIN=frontend yourdockerhubuser/itcyou:latest
#       docker run -d --network host -e ITCYOU_PORT=4000 -e ITCYOU_SUBDOMAIN=api yourdockerhubuser/itcyou:latest
#       docker run -d --network host -e ITCYOU_PORT=5173 -e ITCYOU_SUBDOMAIN=vite yourdockerhubuser/itcyou:latest
#
#  📋 All Environment Variables:
#       ITCYOU_PORT          - (required) Local port to expose          (default: 3000)
#       ITCYOU_SUBDOMAIN     - (optional) Preferred subdomain name      (e.g., "myapp" → https://myapp.it.cyou)
#       ITCYOU_TOKEN         - (optional) API key for auth              (e.g., "itc_yourapikey")
#       ITCYOU_HOST          - (optional) Custom server host            (default: it.cyou)
#       ITCYOU_SERVER_PORT   - (optional) Custom server port            (default: 4443)
#       ITCYOU_INSECURE      - (optional) Skip TLS verify, dev only    (set to "true" to enable)
#
#  ⚠️  IMPORTANT: This image MUST run with --network host on Linux.
#      The itcyou binary needs direct access to localhost to reach your
#      services. network_mode: host makes the container share the host's
#      network stack — no NAT, no bridge, no port mapping needed.
#
#  🐧 Linux Only: network_mode: host works natively on Linux.
#      It does NOT work properly on Docker Desktop (Mac/Windows).
#      Fuck Windows anyway.
#
# =============================================================================


# =============================================================================
# STAGE 1: Builder — Install itcyou binary using the official installer
# =============================================================================
FROM alpine:3.21 AS builder

# curl  → download the installer script from https://it.cyou/install.sh
# bash  → the install script requires bash to run
RUN apk add --no-cache curl bash

# Run the official installer from https://it.cyou/
# This downloads and installs the itcyou binary to the system
RUN curl -fsSL https://it.cyou/install.sh | sh

# Verify the binary was installed and works
# If this fails, the install script may have placed it in a different path.
# Uncomment the find command below to locate it.
# RUN find / -name "itcyou" -type f 2>/dev/null
RUN which itcyou && itcyou version


# =============================================================================
# STAGE 2: Runtime — Minimal Alpine with just the binary
# =============================================================================
FROM alpine:3.21

# --- Metadata Labels ---
LABEL maintainer="yourdockerhubuser"
LABEL org.opencontainers.image.title="itcyou"
LABEL org.opencontainers.image.description="Lightweight tunnel client for https://it.cyou/ — expose localhost to the internet"
LABEL org.opencontainers.image.url="https://it.cyou/"
LABEL org.opencontainers.image.source="https://github.com/yourdockerhubuser/itcyou-docker"

# ca-certificates: Required for TLS/HTTPS connections to the it.cyou server
# Without this, the tunnel handshake will fail with certificate errors
RUN apk add --no-cache ca-certificates

# Copy ONLY the compiled binary from the builder stage
# This keeps the final image tiny — no curl, no bash, no build tools
COPY --from=builder /usr/local/bin/itcyou /usr/local/bin/itcyou

# Make sure the binary is executable
RUN chmod +x /usr/local/bin/itcyou

# Copy and prepare the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# --- Environment Variable Defaults ---
# These can ALL be overridden at runtime via docker run -e or docker-compose.yml

# [REQUIRED] The local port your service is running on
ENV ITCYOU_PORT=3000

# [OPTIONAL] Request a specific subdomain (e.g., "myapp" → https://myapp.it.cyou)
#            Leave empty for a random subdomain
ENV ITCYOU_SUBDOMAIN=""

# [OPTIONAL] Your it.cyou API key for authentication
#            Enables reserved/permanent subdomains
ENV ITCYOU_TOKEN=""

# [OPTIONAL] Custom tunnel server host (default: it.cyou)
ENV ITCYOU_HOST=""

# [OPTIONAL] Custom tunnel server port (default: 4443)
ENV ITCYOU_SERVER_PORT=""

# [OPTIONAL] Set to "true" to skip TLS verification (development only!)
ENV ITCYOU_INSECURE=""

# The entrypoint script reads env vars and builds the itcyou command
ENTRYPOINT ["/entrypoint.sh"]
```

---

#### 🛠️ entrypoint.sh

```bash
#!/bin/sh
# =============================================================================
#  itcyou Docker Entrypoint
#  Reads environment variables and constructs the itcyou command dynamically
# =============================================================================
set -e

echo "============================================"
echo "  🌐 itcyou tunnel client"
echo "  📡 https://it.cyou/"
echo "============================================"

# --- Step 1: Authenticate if a token is provided ---
if [ -n "$ITCYOU_TOKEN" ]; then
  echo ""
  echo "🔑 Authenticating with provided API token..."
  itcyou auth "$ITCYOU_TOKEN"
  echo "✅ Authentication complete"
  echo ""
fi

# --- Step 2: Build the command from env vars ---
CMD="itcyou ${ITCYOU_PORT}"

# Subdomain: -s myapp → https://myapp.it.cyou
if [ -n "$ITCYOU_SUBDOMAIN" ]; then
  CMD="${CMD} -s ${ITCYOU_SUBDOMAIN}"
fi

# Custom server host
if [ -n "$ITCYOU_HOST" ]; then
  CMD="${CMD} -H ${ITCYOU_HOST}"
fi

# Custom server port
if [ -n "$ITCYOU_SERVER_PORT" ]; then
  CMD="${CMD} -p ${ITCYOU_SERVER_PORT}"
fi

# Insecure mode (skip TLS verify — dev only!)
if [ "$ITCYOU_INSECURE" = "true" ]; then
  CMD="${CMD} --insecure"
  echo "⚠️  WARNING: Running in insecure mode (TLS verification disabled)"
fi

# --- Step 3: Print and execute ---
echo ""
echo "🚀 Starting tunnel..."
echo "   Command:  ${CMD}"
echo "   Target:   localhost:${ITCYOU_PORT}"
if [ -n "$ITCYOU_SUBDOMAIN" ]; then
  echo "   URL:      https://${ITCYOU_SUBDOMAIN}.it.cyou"
else
  echo "   URL:      (random — check output below)"
fi
echo ""
echo "============================================"
echo ""

# exec replaces the shell with the itcyou process
# This ensures signals (SIGTERM, SIGINT) go directly to itcyou
# so Docker can gracefully stop the container
exec $CMD
```

---

#### 🧩 docker-compose.yml

```yaml
# =============================================================================
#  itcyou — Docker Compose (Linux, network_mode: host)
#  Official site: https://it.cyou/
# =============================================================================

services:
  # --- Single tunnel ---
  itcyou:
    build: .
    image: yourdockerhubuser/itcyou:latest
    container_name: itcyou-tunnel
    restart: unless-stopped
    network_mode: host                         # 🐧 Linux only — shares host network stack
    environment:
      ITCYOU_PORT: "3000"                      # Your local service port
      ITCYOU_SUBDOMAIN: "myapp"                # → https://myapp.it.cyou
      # ITCYOU_TOKEN: "itc_yourapikey"         # Uncomment & set your API key
      # ITCYOU_HOST: "it.cyou"
      # ITCYOU_SERVER_PORT: "4443"
      # ITCYOU_INSECURE: "true"

  # --- Want multiple tunnels? Uncomment below ---

  # frontend:
  #   build: .
  #   image: yourdockerhubuser/itcyou:latest
  #   container_name: itcyou-frontend
  #   restart: unless-stopped
  #   network_mode: host
  #   environment:
  #     ITCYOU_PORT: "5173"
  #     ITCYOU_SUBDOMAIN: "frontend"
  #     ITCYOU_TOKEN: "itc_yourapikey"

  # api:
  #   build: .
  #   image: yourdockerhubuser/itcyou:latest
  #   container_name: itcyou-api
  #   restart: unless-stopped
  #   network_mode: host
  #   environment:
  #     ITCYOU_PORT: "4000"
  #     ITCYOU_SUBDOMAIN: "myapi"
  #     ITCYOU_TOKEN: "itc_yourapikey"
```

---

#### 📖 README.md

```markdown
# 🌐 itcyou Docker Image

Minimal Docker image for [itcyou](https://it.cyou/) — expose your localhost
services to the internet via secure tunnels.

**~15-25 MB** final image size. Alpine-based. Linux only (network_mode: host).

---

## 🚀 Quick Start

### One-Liner (Random Subdomain)
```bash
docker run -d --rm --name itcyou-tunnel --network host \
  -e ITCYOU_PORT=3000 \
  yourdockerhubuser/itcyou:latest
```

### One-Liner (Custom Subdomain)
```bash
docker run -d --rm --name itcyou-tunnel --network host \
  -e ITCYOU_PORT=3000 \
  -e ITCYOU_SUBDOMAIN=myapp \
  yourdockerhubuser/itcyou:latest
```

### One-Liner (With Auth)
```bash
docker run -d --rm --name itcyou-tunnel --network host \
  -e ITCYOU_PORT=3000 \
  -e ITCYOU_SUBDOMAIN=myapp \
  -e ITCYOU_TOKEN=itc_yourapikey \
  yourdockerhubuser/itcyou:latest
```

### Docker Compose
```bash
docker compose up -d
docker logs -f itcyou-tunnel
```

---

## 📋 Environment Variables

| Variable             | Required | Default  | Description                              |
|----------------------|----------|----------|------------------------------------------|
| `ITCYOU_PORT`        | ✅       | `3000`   | Local port to expose                     |
| `ITCYOU_SUBDOMAIN`   | ❌       | (random) | Preferred subdomain name                 |
| `ITCYOU_TOKEN`       | ❌       | —        | API key for auth & reserved subdomains   |
| `ITCYOU_HOST`        | ❌       | `it.cyou`| Custom tunnel server host                |
| `ITCYOU_SERVER_PORT` | ❌       | `4443`   | Custom tunnel server port                |
| `ITCYOU_INSECURE`    | ❌       | —        | Set `"true"` to skip TLS (dev only)      |

---

## 🏗️ Build & Push

```bash
# Build
docker build -t yourdockerhubuser/itcyou:latest .

# Push to Docker Hub
docker login
docker push yourdockerhubuser/itcyou:latest
```

---

## ⚠️ Requirements

- **Linux only** — `network_mode: host` is required and only works natively on Linux
- Docker 20.10+ / Docker Compose v2+
- Your target service must be running on the host before starting the tunnel
```

---

#### 🔧 Build & Ship Commands

```bash
# 1. Build the image
docker build -t yourdockerhubuser/itcyou:latest .

# 2. Test locally (make sure something is running on port 3000)
docker run --rm --network host \
  -e ITCYOU_PORT=3000 \
  -e ITCYOU_SUBDOMAIN=testrun \
  yourdockerhubuser/itcyou:latest

# 3. Push to Docker Hub
docker login
docker push yourdockerhubuser/itcyou:latest

# 4. Now anyone on Linux can run your image:
docker run -d --rm --name itcyou-tunnel --network host \
  -e ITCYOU_PORT=8080 \
  -e ITCYOU_SUBDOMAIN=coolapp \
  yourdockerhubuser/itcyou:latest
```

---

#### 🎯 Common Usage Examples

```bash
# Expose a Next.js dev server
docker run -d --rm --network host -e ITCYOU_PORT=3000 -e ITCYOU_SUBDOMAIN=mysite yourdockerhubuser/itcyou:latest

# Expose a Vite dev server
docker run -d --rm --network host -e ITCYOU_PORT=5173 -e ITCYOU_SUBDOMAIN=viteapp yourdockerhubuser/itcyou:latest

# Expose a FastAPI / Flask server
docker run -d --rm --network host -e ITCYOU_PORT=8000 -e ITCYOU_SUBDOMAIN=api yourdockerhubuser/itcyou:latest

# Expose Postgres (yes, even TCP services!)
docker run -d --rm --network host -e ITCYOU_PORT=5432 -e ITCYOU_SUBDOMAIN=pgdb yourdockerhubuser/itcyou:latest

# Stop the tunnel
docker stop itcyou-tunnel
```

---

That's the complete package — **Dockerfile, entrypoint, compose, README, and every one-liner you'll ever need**. Just swap `yourdockerhubuser` with your actual Docker Hub username, build, push, and you're live! 🔥🐧