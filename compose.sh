#!/usr/bin/env bash
set -euo pipefail

# TheSereyn.Templates — Compose Script
# Merges base/ + overlays/<template>/ → output/TheSereyn.Templates.<Name>/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$SCRIPT_DIR/base"
OVERLAYS_DIR="$SCRIPT_DIR/overlays"
OUTPUT_DIR="$SCRIPT_DIR/output"

# Template definitions: overlay-folder:OutputRepoName
TEMPLATES=(
  "minimalapi:TheSereyn.Templates.MinimalApi"
  "blazor:TheSereyn.Templates.Blazor"
)

# Optional version tag (set by CI or manually)
TAG="${TAG:-}"

compose_template() {
  local overlay_name="$1"
  local repo_name="$2"
  local target="$OUTPUT_DIR/$repo_name"

  echo "=== Composing $repo_name (base + overlays/$overlay_name) ==="

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
  compose_template "$overlay_name" "$repo_name"
done

echo "All templates composed successfully."
