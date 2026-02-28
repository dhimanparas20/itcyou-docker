#!/bin/sh
set -e

echo "============================================"
echo "  🌐 itcyou tunnel client"
echo "  📡 https://it.cyou/"
echo "============================================"

# --- Build the command from env vars ---
CMD="itcyou ${ITCYOU_PORT}"

# Subdomain: -s myapp → https://myapp.it.cyou
if [ -n "$ITCYOU_SUBDOMAIN" ]; then
  CMD="${CMD} -s ${ITCYOU_SUBDOMAIN}"
fi

# Token: pass DIRECTLY as a flag — NOT via interactive `itcyou auth`
# This is the key fix! `itcyou auth` prompts [y/N] which fails in Docker
if [ -n "$ITCYOU_TOKEN" ]; then
  CMD="${CMD} -t ${ITCYOU_TOKEN}"
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

# --- Print and execute ---
echo ""
echo "🚀 Starting tunnel..."
echo "   Command:  itcyou ${ITCYOU_PORT} [flags]"
echo "   Target:   localhost:${ITCYOU_PORT}"
if [ -n "$ITCYOU_SUBDOMAIN" ]; then
  echo "   URL:      https://${ITCYOU_SUBDOMAIN}.it.cyou"
else
  echo "   URL:      (random — check output below)"
fi
echo ""
echo "============================================"
echo ""

exec $CMD
