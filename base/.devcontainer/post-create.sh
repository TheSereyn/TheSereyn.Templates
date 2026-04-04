#!/usr/bin/env bash
set -euo pipefail

echo "==> Dev container setup starting..."

echo "--> Verifying tool versions"
dotnet --info
node --version
gh --version
az --version

echo "--> Installing GitHub CLI Copilot extension"
gh extension install github/gh-copilot || true

echo "--> Configuring GitHub Copilot CLI shell integration"
cat >> /home/vscode/.bashrc << 'BASHRC'
# GitHub Copilot CLI aliases — activated after gh auth login
if command -v gh &>/dev/null 2>&1; then
  eval "$(gh copilot alias -- bash 2>/dev/null)" 2>/dev/null || true
fi
BASHRC

echo "--> Installing NuGet MCP server (requires .NET 10.0.5+)"
dotnet tool install -g nuget-mcp || true

echo "--> Installing Squad CLI"
npm install -g @bradygaster/squad-cli

echo "==> Dev container setup complete."
echo ""
echo "Next steps:"
echo "  - Run the first-time-setup prompt in Copilot Chat: @workspace /first-time-setup"
echo "  - Azure MCP and Copilot plugin integrations can be configured via Copilot Chat once VS Code has loaded"
