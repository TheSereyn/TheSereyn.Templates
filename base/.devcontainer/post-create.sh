#!/usr/bin/env bash
set -euo pipefail

echo "==> Dev container setup starting..."

# Shared setup (common across all templates)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/post-create-shared.sh"

echo "==> Dev container setup complete."
echo ""
echo "Next steps:"
echo "  - Run the environment check in Copilot Chat: @workspace /environment-check"
echo "  - Then run project setup: @workspace /project-setup"
