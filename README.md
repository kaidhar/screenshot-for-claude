# screenshot-for-claude

Claude Code plugin. Clipboard screenshot → Claude reads it.

## Install

### Claude Code (recommended)

In any Claude Code session:

```
/plugin marketplace add kaidhar/screenshot-for-claude
/plugin install screenshot-for-claude@screenshot-for-claude
```

(Replace `kaidhar` with the GitHub owner if forked.)

Update later: `/plugin marketplace update screenshot-for-claude`.
Remove: `/plugin uninstall screenshot-for-claude@screenshot-for-claude`.

### Manual / other harnesses

Clone the repo, then either:

- Point your harness at this dir as a plugin source, or
- Symlink `commands/ss.md` into `~/.claude/commands/` and the `scripts/` dir somewhere stable, then edit the slash command's path to your scripts dir (replace `${CLAUDE_PLUGIN_ROOT}`).

### Platform prerequisites

- Windows: nothing extra. (Optional) install AutoHotkey v2 + double-click `scripts/hotkey.ahk` for hotkeys.
- macOS: `brew install pngpaste`.
- Linux: `wl-clipboard` (Wayland) or `xclip` (X11).

## Use

1. Copy a screenshot to the clipboard.
   - Windows: Win+Shift+S, click the toast.
   - macOS: Cmd+Shift+Ctrl+4 (region → clipboard).
   - Linux: any tool that puts an image on the clipboard.
2. In Claude Code:

   ```
   /ss what's wrong here?
   ```

3. Plugin saves PNG to `<temp>/claude-screenshots/ss-<timestamp>.png` and Claude reads it.

## Hotkeys (Windows, AutoHotkey v2)

- `Ctrl+Alt+S` → trigger Win+Shift+S region capture.
- `Ctrl+Alt+Shift+S` → capture region, dump to disk, copy file path to clipboard, tray tip with path.

## Retention

Files older than 7 days in the output dir auto-deleted on every run. Override:

- PowerShell: `-RetentionDays 30` (or `0` to disable)
- Bash: `RETENTION_DAYS=30` env var

## Files

- `.claude-plugin/plugin.json` — manifest
- `commands/ss.md` — `/ss` slash command
- `scripts/save-clipboard-image.ps1` — Windows clipboard → PNG
- `scripts/save-clipboard-image.sh` — macOS/Linux clipboard → PNG
- `scripts/dispatch.sh` — shell-side OS dispatcher (used when running outside Claude)
- `scripts/hotkey.ahk` — AutoHotkey v2 hotkey wrapper

## Notes

- Output dir override: `-OutDir <path>` (PS) or `OUT_DIR=<path>` (bash).
- Windows script handles both raw bitmaps and FileDrop (copied image files).
