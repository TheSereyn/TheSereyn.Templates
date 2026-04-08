#!/usr/bin/env bash
set -euo pipefail

echo "==> Dev container setup starting..."

echo "--> Verifying tool versions"
dotnet --info
node --version
python3 --version
gh --version
az --version

echo "--> Installing GitHub CLI Copilot extension"
gh extension install github/gh-copilot || true

echo "--> Configuring GitHub Copilot CLI shell integration"
cat >> /home/vscode/.bashrc << 'BASHRC'
# Ensure ~/.local/bin is on PATH (uv tools, pip --user installs)
export PATH="$HOME/.local/bin:$PATH"

# GitHub Copilot CLI aliases — activated after gh auth login
if command -v gh &>/dev/null 2>&1; then
  eval "$(gh copilot alias -- bash 2>/dev/null)" 2>/dev/null || true
fi
BASHRC

echo "--> Installing NuGet MCP server (requires .NET 10.0.5+)"
dotnet tool install -g nuget-mcp || true

echo "--> Installing Squad CLI"
npm install -g @bradygaster/squad-cli

echo "--> Installing uv (Python package manager)"
python3 -m pip install --user --quiet uv
export PATH="$HOME/.local/bin:$PATH"

echo "--> Installing Spec Kit CLI (pinned to v0.5.0)"
uv tool install specify-cli --from "git+https://github.com/github/spec-kit.git@v0.5.0" || true

echo "--> Installing microsoftdocs/mcp plugin skills"
MSDOCS_RAW="https://raw.githubusercontent.com/microsoftdocs/mcp/main"
COPILOT_DIR="/home/vscode/.copilot"
SKILLS_DIR="$COPILOT_DIR/skills"
for skill in microsoft-docs microsoft-code-reference microsoft-skill-creator; do
  mkdir -p "$SKILLS_DIR/$skill"
  curl -sL "$MSDOCS_RAW/skills/$skill/SKILL.md" -o "$SKILLS_DIR/$skill/SKILL.md" || true
done
mkdir -p "$SKILLS_DIR/microsoft-skill-creator/references"
curl -sL "$MSDOCS_RAW/skills/microsoft-skill-creator/references/skill-templates.md" \
  -o "$SKILLS_DIR/microsoft-skill-creator/references/skill-templates.md" || true

echo "--> Seeding user-level Copilot MCP config"
COPILOT_MCP="$COPILOT_DIR/mcp.json"
if [ ! -f "$COPILOT_MCP" ]; then
  cat > "$COPILOT_MCP" << 'MCP_EOF'
{
  "mcpServers": {
    "microsoft-learn": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp"
    }
  }
}
MCP_EOF
fi

echo "==> Dev container setup complete."
echo ""
echo "Next steps:"
echo "  - Run the first-time-setup prompt in Copilot Chat: @workspace /first-time-setup"
