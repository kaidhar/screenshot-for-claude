; AutoHotkey v2 hotkey wrapper for screenshot-for-claude.
; Ctrl+Alt+S: launch Snipping Tool region capture. After capture, image lands
; on the clipboard. Then run /ss in Claude Code.
;
; Ctrl+Alt+Shift+S: capture region AND immediately dump to disk via the
; PowerShell helper, copy the path to clipboard, and show a tray tip with it.
;
; Install: install AutoHotkey v2 (https://www.autohotkey.com/), then double-click
; this file or add it to shell:startup for autostart.

#Requires AutoHotkey v2.0
#SingleInstance Force

ScriptDir := A_ScriptDir
PSScript  := ScriptDir "\save-clipboard-image.ps1"

TriggerSnip() {
    Send("#+s")  ; Win+Shift+S
}

^!s::TriggerSnip()

^!+s:: {
    A_Clipboard := ""
    TriggerSnip()
    if !ClipWait(15, 2) {
        TrayTip("screenshot-for-claude", "No image captured within 15s.", 0x2)
        return
    }
    try {
        out := RunWaitCapture('powershell.exe -ExecutionPolicy Bypass -NoProfile -File "' PSScript '"')
        path := Trim(out, " `r`n`t")
        if path != "" && FileExist(path) {
            A_Clipboard := path
            TrayTip("screenshot-for-claude", "Saved: " path "`nPath copied to clipboard.", 0x1)
        } else {
            TrayTip("screenshot-for-claude", "Helper returned no path.", 0x2)
        }
    } catch as err {
        TrayTip("screenshot-for-claude", "Error: " err.Message, 0x2)
    }
}

RunWaitCapture(cmd) {
    shell := ComObject("WScript.Shell")
    exec  := shell.Exec(cmd)
    out   := exec.StdOut.ReadAll()
    return out
}
