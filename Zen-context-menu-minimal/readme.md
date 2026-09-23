# Zen Minimal Context Menu

This mod keeps the tab, page, link, and image context-menu actions left unmarked in the supplied screenshots. It hides the crossed-out built-in actions and keeps extension menus available. It also removes dividers.

The upstream Zen Context Menu stylesheet has a positional `:nth-child(21)` fallback in its Duplicate Tab hide rule. A tab menu row added or removed before that position can make the rule target a different row. This mod uses named menu IDs and an allowlist instead.

## Install

1. Open Settings → Zen Mods → Import.
2. Select `zen-mods-export.json` from the delivered `outputs` folder.
3. Enable **Zen Minimal Context Menu**. Leave the original **Zen Context Menu** mod disabled.
4. Right-click a tab, page, link, and image to check each menu.

The import file fetches the stylesheet from this fork's `minimal-context-menu` branch. The branch must be published to GitHub before Zen can install it.
