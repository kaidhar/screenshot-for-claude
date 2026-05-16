---
description: Save clipboard image to disk and read it.
argument-hint: "[optional note]"
allowed-tools: Bash, Read
---

Detect the OS and dump the clipboard image to a temp PNG. On Windows use PowerShell; elsewhere use the POSIX helper.

!`bash -c 'case "$(uname -s 2>/dev/null)" in Darwin|Linux*) bash "${CLAUDE_PLUGIN_ROOT}/scripts/save-clipboard-image.sh" ;; *) powershell.exe -ExecutionPolicy Bypass -NoProfile -File "${CLAUDE_PLUGIN_ROOT}/scripts/save-clipboard-image.ps1" ;; esac' 2>&1 || powershell.exe -ExecutionPolicy Bypass -NoProfile -File "${CLAUDE_PLUGIN_ROOT}\scripts\save-clipboard-image.ps1"`

The last non-error line of the command output is the absolute path of the saved screenshot.

If a path was returned:
1. Read the file at that exact path.
2. Address the user's note (if any): $ARGUMENTS

If an error was returned, tell the user no image was on the clipboard and to copy one first (Win+Shift+S on Windows, Cmd+Shift+4 then Ctrl on macOS, screenshot tool that copies on Linux).
