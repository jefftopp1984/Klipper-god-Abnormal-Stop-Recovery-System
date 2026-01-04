#!/bin/bash
set -e

# ===============================
# Configuration
# ===============================

SAVE_VARS="/home/sonic/klipper/variables.cfg"
GCODE_DIR="/home/sonic/printer_data/gcodes"
CURRENT_FILE_TXT="${GCODE_DIR}/current_print.txt"
OUTPUT_FILE="${GCODE_DIR}/recovered.gcode"

# ===============================
# Extract persisted values
# ===============================

# Filename only (as stored)
CRM4_FILENAME="$(cat "$CURRENT_FILE_TXT" 2>/dev/null || true)"

# Build full path
CRM4_CURRENT_PRINT="${GCODE_DIR}/${CRM4_FILENAME}"

# Extract crm4_print_progress from variables.cfg (INI-style)
CRM4_PRINT_PROGRESS=$(awk -F= '
    $1 ~ /^[[:space:]]*crm4_print_progress[[:space:]]*$/ {
        gsub(/[[:space:]]*/, "", $2)
        print $2
    }
' "$SAVE_VARS")

# Extract crm4_z_height from variables.cfg (INI-style)
CRM4_Z_HEIGHT=$(awk -F= '
    $1 ~ /^[[:space:]]*crm4_z_height[[:space:]]*$/ {
        gsub(/[[:space:]]*/, "", $2)
        print $2
    }
' "$SAVE_VARS")

# ===============================
# Validation
# ===============================

if [ -z "$CRM4_FILENAME" ]; then
    echo "ERROR: current_print.txt is empty or missing"
    exit 1
fi

if [ -z "$CRM4_PRINT_PROGRESS" ]; then
    echo "ERROR: crm4_print_progress is empty"
    exit 1
fi

if [ "$CRM4_PRINT_PROGRESS" -lt 1 ] 2>/dev/null; then
    echo "ERROR: Invalid layer index"
    exit 1
fi

if [ ! -f "$CRM4_CURRENT_PRINT" ]; then
    echo "ERROR: G-code file not found: $CRM4_CURRENT_PRINT"
    exit 1
fi

# ===============================
# Generate recovered.gcode
# ===============================

TARGET_LINE="SET_PRINT_STATS_INFO CURRENT_LAYER=${CRM4_PRINT_PROGRESS}"

awk -v target="$TARGET_LINE" '
    BEGIN { found=0 }
    {
        if (found) {
            print
        }
        if (index($0, target)) {
            found=1
        }
    }
' "$CRM4_CURRENT_PRINT" > "$OUTPUT_FILE"

# ===============================
# Verify success
# ===============================

if [ ! -s "$OUTPUT_FILE" ]; then
    echo "ERROR: recovered.gcode is empty or layer marker not found"
    exit 1
fi

echo "Recovery file generated successfully:"
echo "  Source file: $CRM4_CURRENT_PRINT"
echo "  Output file: $OUTPUT_FILE"
echo "  Layer: $CRM4_PRINT_PROGRESS"
echo "  Z: $CRM4_Z_HEIGHT"

exit 0
