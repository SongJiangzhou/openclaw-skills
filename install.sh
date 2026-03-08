#!/bin/bash
# OpenClaw Skills Installer (English)
# Wraps install.mjs — handles Node.js bootstrap and dependency check.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check Node.js
if ! command -v node > /dev/null 2>&1; then
    echo "Error: Node.js is required but not found."
    echo "Install it from https://nodejs.org (v18+ recommended)"
    exit 1
fi

# Auto-install dependencies if needed
if [ ! -d "$SCRIPT_DIR/node_modules" ]; then
    echo "Installing dependencies..."
    (cd "$SCRIPT_DIR" && npm install --silent)
fi

# Run the unified installer
INSTALLER_LANG=en exec node "$SCRIPT_DIR/install.mjs" "$@"
