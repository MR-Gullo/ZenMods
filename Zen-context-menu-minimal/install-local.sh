#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
MOD_ID="d1f76f4f-b736-4ae5-87a9-25d6f082f5ce"
PROFILE_DIR="${1:-}"

if [[ -z "$PROFILE_DIR" ]]; then
  printf 'Paste the Zen profile folder path: '
  IFS= read -r PROFILE_DIR
fi

case "$PROFILE_DIR" in
  '~') PROFILE_DIR="$HOME" ;;
  '~/'*) PROFILE_DIR="$HOME/${PROFILE_DIR#~/}" ;;
esac
PROFILE_DIR="${PROFILE_DIR%/}"

if [[ ! -d "$PROFILE_DIR" || ! -f "$PROFILE_DIR/prefs.js" ]]; then
  printf 'That path does not look like a Zen profile. Find it at about:support → Profile Folder.\n' >&2
  exit 1
fi

MODS_FILE="$PROFILE_DIR/zen-themes.json"
python3 - "$MODS_FILE" <<'PYTHON'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
if path.exists():
    try:
        current = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"Cannot read {path}: {exc}")
    if not isinstance(current, dict):
        raise SystemExit(f"Expected a JSON object in {path}; left it unchanged.")
PYTHON

STAMP="$(date +%Y%m%d-%H%M%S)-$$"
BACKUP_FILE=""
if [[ -f "$MODS_FILE" ]]; then
  BACKUP_FILE="$MODS_FILE.backup-$STAMP"
  cp -p "$MODS_FILE" "$BACKUP_FILE"
fi

MOD_DIR="$PROFILE_DIR/chrome/zen-themes/$MOD_ID"
if [[ -d "$MOD_DIR" ]]; then
  cp -R "$MOD_DIR" "$MOD_DIR.backup-$STAMP"
fi
mkdir -p "$MOD_DIR"
cp "$SCRIPT_DIR/chrome.css" "$MOD_DIR/chrome.css"
cp "$SCRIPT_DIR/preferences.json" "$MOD_DIR/preferences.json"
cp "$SCRIPT_DIR/readme.md" "$MOD_DIR/readme.md"

python3 - "$MODS_FILE" "$MOD_ID" <<'PYTHON'
import json
import os
import pathlib
import sys
import tempfile

path = pathlib.Path(sys.argv[1])
mod_id = sys.argv[2]
mods = json.loads(path.read_text()) if path.exists() else {}
mods[mod_id] = {
    "id": mod_id,
    "name": "Zen Minimal Context Menu",
    "description": "Keep only the selected tab, page, link, and image context menu actions.",
    "homepage": "https://github.com/MR-Gullo/ZenMods/tree/minimal-context-menu/Zen-context-menu-minimal",
    "author": "MR-Gullo",
    "version": "1.0.0",
    "style": "local",
    "readme": "local",
    "preferences": "local",
    "enabled": True,
}
fd, temp_name = tempfile.mkstemp(prefix="zen-themes.", suffix=".json.tmp", dir=path.parent)
try:
    with os.fdopen(fd, "w") as stream:
        json.dump(mods, stream, indent=2)
        stream.write("\n")
    os.replace(temp_name, path)
except Exception:
    try:
        os.unlink(temp_name)
    except FileNotFoundError:
        pass
    raise
PYTHON

THEMES_CSS="$PROFILE_DIR/chrome/zen-themes.css"
THEMES_CSS_BACKUP=""
if [[ -f "$THEMES_CSS" ]]; then
  THEMES_CSS_BACKUP="$THEMES_CSS.backup-$STAMP"
  cp -p "$THEMES_CSS" "$THEMES_CSS_BACKUP"
fi
python3 - "$THEMES_CSS" "$SCRIPT_DIR/chrome.css" "$MOD_ID" <<'PYTHON'
import os
import pathlib
import stat
import sys
import tempfile

target = pathlib.Path(sys.argv[1])
source = pathlib.Path(sys.argv[2]).read_text()
mod_id = sys.argv[3]
begin = f"/* BEGIN Zen Minimal Context Menu {mod_id} */"
end = f"/* END Zen Minimal Context Menu {mod_id} */"
block = f"{begin}\n{source.rstrip()}\n{end}"
target.parent.mkdir(parents=True, exist_ok=True)
content = target.read_text() if target.exists() else ""
start = content.find(begin)
if start >= 0:
    finish = content.find(end, start)
    if finish < 0:
        raise SystemExit(f"Found an incomplete local stylesheet block in {target}; left it unchanged.")
    finish += len(end)
    content = content[:start] + block + content[finish:]
elif source.strip() not in content:
    content = content.rstrip() + ("\n\n" if content else "") + block + "\n"

fd, temp_name = tempfile.mkstemp(prefix="zen-themes.css.", suffix=".tmp", dir=target.parent)
try:
    with os.fdopen(fd, "w") as stream:
        stream.write(content)
    if target.exists():
        os.chmod(temp_name, stat.S_IMODE(target.stat().st_mode))
    os.replace(temp_name, target)
except Exception:
    try:
        os.unlink(temp_name)
    except FileNotFoundError:
        pass
    raise
PYTHON

printf 'Installed Zen Minimal Context Menu in: %s\n' "$PROFILE_DIR"
if [[ -n "$BACKUP_FILE" ]]; then
  printf 'Backup of the previous mod list: %s\n' "$BACKUP_FILE"
fi
printf 'Fully quit Zen before running this script. Reopen Zen after it finishes.\n'
