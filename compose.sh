#!/usr/bin/env bash
set -euo pipefail

# TheSereyn.Templates — Compose Script
# Merges base/ + overlays/<template>/ → output/TheSereyn.Templates.<Name>/
#
# Composition is authoritative: the output/ directory is the single source of
# truth for each downstream template repo. Never edit output/ directly — always
# change base/ or overlays/ and re-run this script.
#
# Template registry: templates are defined in templates.json at the repo root.
# Both this script and the CI workflow matrix read from that file, ensuring a
# single source of truth when adding or removing templates.
#
# Usage:
#   ./compose.sh                   Compose all templates
#   ./compose.sh --only blazor     Compose only the blazor overlay
#   ./compose.sh --dry-run         Show what would be composed without writing
#
# Drift note: The Blazor overlay replaces devcontainer.json and mcp-config.json
# entirely. If the base versions of these files change, check the Blazor overlay
# copies for divergence and reconcile manually.
#
# Future — mixin/layer support: When 3+ templates share a common overlay
# fragment (e.g., Playwright setup), introduce a mixins/ directory and process
# mixin layers between base/ and the template-specific overlay. Track the need
# at 4+ templates.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$SCRIPT_DIR/base"
OVERLAYS_DIR="$SCRIPT_DIR/overlays"
OUTPUT_DIR="$SCRIPT_DIR/output"

# Template definitions from templates.json (single source of truth)
TEMPLATES_JSON="$SCRIPT_DIR/templates.json"
if [[ ! -f "$TEMPLATES_JSON" ]]; then
  echo "Error: templates.json not found at $TEMPLATES_JSON" >&2
  exit 1
fi
mapfile -t TEMPLATES < <(jq -r '.[] | "\(.overlay):\(.repo | split("/") | last)"' "$TEMPLATES_JSON")

# Optional version tag (set by CI or manually)
TAG="${TAG:-}"

# Parse arguments
ONLY_TEMPLATE=""
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --only) ONLY_TEMPLATE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) shift ;;
  esac
done

compose_template() {
  local overlay_name="$1"
  local repo_name="$2"
  local target="$OUTPUT_DIR/$repo_name"

  echo "=== Composing $repo_name (base + overlays/$overlay_name) ==="

  if [[ "$DRY_RUN" == "true" ]]; then
    local base_count overlay_count append_count
    base_count=$(find "$BASE_DIR" -type f | wc -l | tr -d ' ')
    overlay_count=0
    append_count=0
    local overlay_dir="$OVERLAYS_DIR/$overlay_name"
    if [[ -d "$overlay_dir" ]]; then
      overlay_count=$(find "$overlay_dir" -type f | wc -l | tr -d ' ')
      append_count=$(find "$overlay_dir" -name '*.append.md' | wc -l | tr -d ' ')
    fi
    echo "  [DRY RUN] Would write to: $target"
    echo "  [DRY RUN] Base files:    $base_count"
    echo "  [DRY RUN] Overlay files: $overlay_count (includes $append_count .append.md)"
    echo ""
    return
  fi

  # Clean target, preserving .git/ if it exists
  if [[ -d "$target" ]]; then
    find "$target" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
  else
    mkdir -p "$target"
  fi

  # Step 1: Copy base files
  cp -a "$BASE_DIR/." "$target/"

  # Step 2: Copy overlay files on top (overwrites same paths)
  local overlay_dir="$OVERLAYS_DIR/$overlay_name"
  if [[ -d "$overlay_dir" ]]; then
    cp -a "$overlay_dir/." "$target/"
  fi

  # Step 3: Process *.append.md files
  while IFS= read -r -d '' append_file; do
    local rel_path="${append_file#"$target/"}"
    # Strip .append from filename: foo.append.md → foo.md
    local base_name
    base_name="$(echo "$rel_path" | sed 's/\.append\.md$/.md/')"
    local base_file="$target/$base_name"

    if [[ -f "$base_file" ]]; then
      # Append with blank line separator
      printf '\n\n' >> "$base_file"
      cat "$append_file" >> "$base_file"
      rm "$append_file"
      echo "  Appended: $rel_path → $base_name"
    else
      # No base file to append to — rename the file (strip .append)
      local dest="$target/$base_name"
      mkdir -p "$(dirname "$dest")"
      mv "$append_file" "$dest"
      echo "  Renamed (no base): $rel_path → $base_name"
    fi
  done < <(find "$target" -name '*.append.md' -print0 2>/dev/null)

  # Step 4: Stamp version footer if TAG is set
  if [[ -n "$TAG" && -f "$target/README.md" ]]; then
    printf '\n---\n\n*Composed from [TheSereyn.Templates](https://github.com/TheSereyn/TheSereyn.Templates) @ %s*\n' "$TAG" >> "$target/README.md"
  fi

  echo "  Done → $target"
  echo ""
}

# Main
echo "TheSereyn.Templates — Compose"
echo ""

for entry in "${TEMPLATES[@]}"; do
  IFS=':' read -r overlay_name repo_name <<< "$entry"
  # Skip if --only is set and doesn't match this template
  if [[ -n "$ONLY_TEMPLATE" && "$overlay_name" != "$ONLY_TEMPLATE" && "$repo_name" != "$ONLY_TEMPLATE" ]]; then
    continue
  fi
  compose_template "$overlay_name" "$repo_name"
done

echo "All templates composed successfully."
