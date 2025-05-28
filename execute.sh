#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$CURRENT_DIR/repos.conf"
CURRENT_MINUTE=$(date +%s)
LOG_DIR="$CURRENT_DIR/logs"

mkdir -p "$LOG_DIR"

while IFS= read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  IFS=':' read -r INTERVAL REPO_DIR BRANCH <<< "$line"

  HASH=$(echo -n "$REPO_DIR" | /sbin/md5 | awk '{print $NF}')
  STATE_FILE="/tmp/last_run_$HASH"
  LOG_FILE="$LOG_DIR/$(basename "$REPO_DIR").log"

  if [[ -f "$STATE_FILE" ]]; then
    LAST_RUN=$(cat "$STATE_FILE")
    ELAPSED=$(( (CURRENT_MINUTE - LAST_RUN) / 60 ))
  else
    ELAPSED=$INTERVAL
  fi

  if (( ELAPSED >= INTERVAL )); then
    echo "$CURRENT_MINUTE" > "$STATE_FILE"

    if ! cd "$REPO_DIR" 2>/dev/null; then
      echo "=== Run at $(date '+%Y-%m-%d %H:%M:%S') for $REPO_DIR on branch $BRANCH ===" >> "$LOG_FILE"
      echo "ERROR: Cannot change directory to $REPO_DIR" >> "$LOG_FILE"
      continue
    fi

    # Only log if actual changes exist (either unstaged or staged)
    if ! git diff --quiet || ! git diff --cached --quiet; then
      {
        echo "=== Run at $(date '+%Y-%m-%d %H:%M:%S') for $REPO_DIR on branch $BRANCH ==="
        echo "Changes detected, attempting commit and push..."
        git add .
        
        DATE=$(date '+%Y-%m-%d %H:%M:%S')
        if git commit -m "Auto commit at $DATE"; then
          echo "Commit successful."
        else
          echo "No commit created (possibly no changes)."
        fi

        if git push origin "$BRANCH"; then
          echo "Push successful."
        else
          echo "ERROR: Push failed."
        fi
      } >> "$LOG_FILE" 2>&1
    fi
  fi
done < "$CONFIG_FILE"

