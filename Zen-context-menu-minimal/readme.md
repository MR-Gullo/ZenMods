# Zen Minimal Context Menu

Keeps the tab, page, link, and image menu actions left unmarked in the supplied screenshots. It hides crossed-out built-in actions, keeps extension menus, and removes dividers.

## Local test install

Zen's Import button only resolves mod IDs from the official theme store. It ignores asset URLs in an imported JSON file, so it cannot install this unpublished mod ID. Use the included local installer instead.

1. In Zen, open `about:support` and copy the **Profile Folder** path.
2. Fully quit Zen.
3. In Terminal, run `bash "/path/to/install-local.sh" "/path/to/your/Zen/profile"`, replacing both paths. If you omit the profile path, the script prompts for it.
4. Reopen Zen. Zen loads the compiled stylesheet from `chrome/zen-themes.css`; the installer adds this mod's CSS there and enables the local entry. Leave the original **Zen Context Menu** disabled.

The installer preserves your existing `zen-themes.json` entries and `chrome/zen-themes.css`, with timestamped backups before it edits either file. It also keeps a backup if this mod folder already exists. The CSS block has markers, so repeated installs replace it instead of adding duplicates. Zen rebuilds the generated stylesheet from enabled mods after its next in-app mod change.

To remove the test mod, use **Remove** next to it in Settings → Zen Mods. Zen removes its local files and its entry from the mod list.
