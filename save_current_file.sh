#!/bin/bash
set -e

OUT_FILE="/home/sonic/printer_data/gcodes/current_print.txt"
MOONRAKER_PORT=7125   # CR-6 SE instance
URL="http://127.0.0.1:${MOONRAKER_PORT}/printer/objects/query?print_stats"

# Query Moonraker and extract filename WITHOUT jq
FILENAME=$(
  curl -s "$URL" \
  | sed -n 's/.*"filename":[[:space:]]*"\([^"]*\)".*/\1/p'
)

if [ -z "$FILENAME" ]; then
    echo "ERROR: Could not extract filename from Moonraker"
    exit 1
fi

echo "$FILENAME" > "$OUT_FILE"
exit 0
