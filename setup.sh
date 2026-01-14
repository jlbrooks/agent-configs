#!/usr/bin/env bash
set -u
IFS=$'\n\t'

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

ASSUME_YES=0
SHOW_DIFF=1

usage() {
  cat <<'USAGE'
Usage: ./setup.sh [--yes] [--no-diff]

Interactive installer for AI agent configs.

Options:
  --yes, -y     Accept all prompts (overwrite/install without asking)
  --no-diff     Skip showing diffs when existing configs differ
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y) ASSUME_YES=1 ;;
    --no-diff) SHOW_DIFF=0 ;;
    --help|-h) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

confirm() {
  local prompt="$1"
  local default="${2:-N}"
  local reply

  if [ "$ASSUME_YES" -eq 1 ]; then
    return 0
  fi

  if [ "$default" = "Y" ]; then
    read -r -p "$prompt [Y/n] " reply
  else
    read -r -p "$prompt [y/N] " reply
  fi

  if [ -z "$reply" ]; then
    reply="$default"
  fi

  case "$reply" in
    [Yy]*) return 0 ;;
    *) return 1 ;;
  esac
}

show_diff() {
  local src="$1"
  local dest="$2"

  echo "Diff (first 200 lines):"
  if [ -d "$src" ] && [ -d "$dest" ]; then
    diff -ru "$dest" "$src" | head -n 200 || true
  else
    diff -u "$dest" "$src" | head -n 200 || true
  fi
}

link_item() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname -- "$dest")"
  ln -s "$src" "$dest"
}

is_same_link() {
  local src="$1"
  local dest="$2"

  if [ ! -L "$dest" ]; then
    return 1
  fi

  local dest_target
  dest_target="$(readlink -f "$dest")"
  [ "$dest_target" = "$src" ]
}

backup_item() {
  local dest="$1"
  local bak="${dest}.bak"

  if [ -e "$bak" ]; then
    rm -rf "$bak"
  fi
  mv "$dest" "$bak"
}

ITEMS=(
  ".claude/settings.json|$HOME/.claude/settings.json"
  "AGENTS.md|$HOME/.codex/AGENTS.md"
  "CLAUDE.md|$HOME/.claude/CLAUDE.md"
  "commands|$HOME/.claude/commands"
  "commands|$HOME/.codex/prompts"
  "hooks|$HOME/.claude/hooks"
)

# Special handling for config.toml (merge, not symlink)
CODEX_CONFIG_SRC="$REPO_ROOT/.codex/config.toml"
CODEX_CONFIG_DEST="$HOME/.codex/config.toml"
MARKER="# --- Everything above managed by agent-configs ---"

merge_codex_config() {
  echo "==> .codex/config.toml (merge)"

  mkdir -p "$(dirname -- "$CODEX_CONFIG_DEST")"

  if [ ! -e "$CODEX_CONFIG_DEST" ]; then
    echo "  No existing config. Copying base."
    cp "$CODEX_CONFIG_SRC" "$CODEX_CONFIG_DEST"
    installed+=(".codex/config.toml")
    return
  fi

  # If it's a symlink, remove it first
  if [ -L "$CODEX_CONFIG_DEST" ]; then
    echo "  Removing old symlink."
    rm "$CODEX_CONFIG_DEST"
  fi

  # Extract local project trust entries (lines starting with [projects. and following trust_level)
  # that aren't already in the repo config
  local local_projects
  local_projects=$(awk '
    /^\[projects\./ {
      section = $0
      getline
      if ($0 ~ /^trust_level/) {
        entry = section "\n" $0
        projects[section] = entry
      }
    }
    END {
      for (p in projects) print projects[p] "\n"
    }
  ' "$CODEX_CONFIG_DEST")

  local repo_projects
  repo_projects=$(grep -E '^\[projects\.' "$CODEX_CONFIG_SRC" || true)

  # Start with repo config
  cp "$CODEX_CONFIG_SRC" "$CODEX_CONFIG_DEST"

  # Append local project entries not in repo
  while IFS= read -r line; do
    if [[ "$line" =~ ^\[projects\. ]]; then
      if ! grep -qF "$line" "$CODEX_CONFIG_SRC"; then
        echo "" >> "$CODEX_CONFIG_DEST"
        echo "$line" >> "$CODEX_CONFIG_DEST"
        # Read next line (trust_level)
        IFS= read -r trust_line
        echo "$trust_line" >> "$CODEX_CONFIG_DEST"
      fi
    fi
  done <<< "$local_projects"

  echo "  Merged. Local project trust entries preserved."
  installed+=(".codex/config.toml")
}

installed=()
skipped=()
unchanged=()

for entry in "${ITEMS[@]}"; do
  src_rel="${entry%%|*}"
  dest="${entry#*|}"
  src="$REPO_ROOT/$src_rel"

  echo "==> $src_rel"

  if [ ! -e "$src" ]; then
    echo "  Skipping: source not found at $src"
    skipped+=("$src_rel")
    continue
  fi

  if [ -e "$dest" ]; then
    if is_same_link "$src" "$dest"; then
      echo "  Already linked."
      unchanged+=("$src_rel")
      continue
    fi

    same_content=0
    if [ -d "$src" ] && [ -d "$dest" ]; then
      if diff -rq "$dest" "$src" >/dev/null 2>&1; then
        same_content=1
      fi
    elif [ -f "$src" ] && [ -f "$dest" ]; then
      if cmp -s "$dest" "$src"; then
        same_content=1
      fi
    fi

    if [ "$same_content" -eq 1 ]; then
      echo "  Content matches, but it's not a symlink."
    else
      echo "  Existing config differs at $dest"
      if [ "$SHOW_DIFF" -eq 1 ]; then
        show_diff "$src" "$dest"
      fi
    fi

    if confirm "  Replace with symlink to repo version?" N; then
      backup_item "$dest"
      link_item "$src" "$dest"
      installed+=("$src_rel")
      echo "  Linked."
    else
      skipped+=("$src_rel")
      echo "  Skipped."
    fi
  else
    echo "  No existing config at $dest"
    if confirm "  Create symlink?" Y; then
      link_item "$src" "$dest"
      installed+=("$src_rel")
      echo "  Linked."
    else
      skipped+=("$src_rel")
      echo "  Skipped."
    fi
  fi

done

# Handle config.toml merge separately
merge_codex_config

echo
if [ ${#installed[@]} -gt 0 ]; then
  echo "Installed: ${installed[*]}"
fi
if [ ${#unchanged[@]} -gt 0 ]; then
  echo "Unchanged: ${unchanged[*]}"
fi
if [ ${#skipped[@]} -gt 0 ]; then
  echo "Skipped: ${skipped[*]}"
fi
