#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$CURRENT_DIR/repos.conf"
EXAMPLE_FILE="$CURRENT_DIR/repos.conf.example"

# If repos.conf does not exist, create it from repos.conf.example
if [[ ! -f "$CONFIG_FILE" ]]; then
  if [[ -f "$EXAMPLE_FILE" ]]; then
    cp "$EXAMPLE_FILE" "$CONFIG_FILE"
    echo "Created $CONFIG_FILE from $EXAMPLE_FILE"
  else
    echo "Error: $EXAMPLE_FILE not found. Cannot create $CONFIG_FILE."
    exit 1
  fi
fi

echo "Enter interval (minutes):"
read -r INTERVAL

echo "Enter repository absolute path:"
read -r REPO_DIR

echo "Enter branch name:"
read -r BRANCH

# Simple validation for empty inputs
if [[ -z "$INTERVAL" || -z "$REPO_DIR" || -z "$BRANCH" ]]; then
  echo "Error: All inputs are required."
  exit 1
fi

# Append to the config file
echo "${INTERVAL}:${REPO_DIR}:${BRANCH}" >> "$CONFIG_FILE"
echo "Added entry to $CONFIG_FILE:"
echo "${INTERVAL}:${REPO_DIR}:${BRANCH}"

