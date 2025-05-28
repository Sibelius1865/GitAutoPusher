#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXECUTE_PATH="$CURRENT_DIR/execute.sh"
ADD_PATH="$CURRENT_DIR/add.sh"
LOG_PATH="$CURRENT_DIR/cron.log"
CRON_LINE="* * * * * /bin/bash \"$EXECUTE_PATH\" >> \"$LOG_PATH\" 2>&1"

# === Step 1a: make execute.sh executable ===
if [[ -f "$EXECUTE_PATH" ]]; then
  chmod +x "$EXECUTE_PATH"
  echo "Set executable permission on $EXECUTE_PATH"
else
  echo "File not found: $EXECUTE_PATH"
  exit 1
fi

# === Step 1b: make add.sh executable ===
if [[ -f "$ADD_PATH" ]]; then
  chmod +x "$ADD_PATH"
  echo "Set executable permission on $ADD_PATH"
else
  echo "File not found: $ADD_PATH"
  exit 1
fi

# === Step 2: Add to crontab ===
TEMP_CRON_FILE="/tmp/current_cron"

crontab -l 2>/dev/null | grep -v "$EXECUTE_PATH" > "$TEMP_CRON_FILE"

echo "$CRON_LINE" >> "$TEMP_CRON_FILE"

crontab "$TEMP_CRON_FILE"
rm "$TEMP_CRON_FILE"

echo "Crontab entry installed:"
echo "$CRON_LINE"
