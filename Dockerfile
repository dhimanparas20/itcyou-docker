# =========== Build Stage ===========
FROM alpine:3.21 AS builder

RUN apk add --no-cache curl bash

# Install itcyou via official installer
RUN curl -fsSL https://it.cyou/install.sh | sh

# Debug: find where binary landed (remove after first successful build)
RUN which itcyou || find / -name "itcyou" 2>/dev/null
RUN itcyou version

# =========== Runtime Stage ===========
FROM alpine:3.21

# TLS certs so the tunnel can do HTTPS
RUN apk add --no-cache ca-certificates

# Grab the binary from builder
COPY --from=builder /usr/local/bin/itcyou /usr/local/bin/itcyou

# Entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Configurable via env vars
ENV ITCYOU_PORT=3000
ENV ITCYOU_SUBDOMAIN=""
ENV ITCYOU_TOKEN=""
ENV ITCYOU_HOST=""
ENV ITCYOU_SERVER_PORT=""
ENV ITCYOU_INSECURE=""

# Health check - verify tunnel process is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD pgrep -x "itcyou" > /dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]

# =============================================================================
# License: MIT License
# See LICENSE file in the repository root for full license text.
# GitHub: https://github.com/dhimanparas20/itcyou-docker
# =============================================================================
