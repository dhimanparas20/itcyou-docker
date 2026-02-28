#!/bin/sh
set -e

# --- Auth if token provided ---
if [ -n "$ITCYOU_TOKEN" ]; then
  echo "🔑 Authenticating..."
  itcyou auth "$ITCYOU_TOKEN"
fi

# --- Build command dynamically ---
CMD="itcyou ${ITCYOU_PORT}"

[ -n "$ITCYOU_SUBDOMAIN" ]    && CMD="${CMD} -s ${ITCYOU_SUBDOMAIN}"
[ -n "$ITCYOU_HOST" ]         && CMD="${CMD} -H ${ITCYOU_HOST}"
[ -n "$ITCYOU_SERVER_PORT" ]  && CMD="${CMD} -p ${ITCYOU_SERVER_PORT}"
[ "$ITCYOU_INSECURE" = "true" ] && CMD="${CMD} --insecure"

echo "🚀 Running: ${CMD}"
exec $CMD
