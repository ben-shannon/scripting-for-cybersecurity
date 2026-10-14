#!/bin/bash

REPORT=""

for CONF in case/configs/*.conf; do
    PORT=$(grep '^port=' "$CONF" | cut -d'=' -f2)
    if [ -z "$PORT" ]; then
        PORT="(none)"
    fi
    REPORT="${REPORT}${CONF}: port ${PORT}"$'\n'
done

echo "Configured ports:"
echo "$REPORT"
