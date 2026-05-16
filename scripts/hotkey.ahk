; AutoHotkey v2 hotkey wrapper for screenshot-paste.
;
; Hotkeys:
;   Alt+Shift+S   → region capture, save to PNG, type path into focused window
;                   (use in Claude Code terminal: it appears as `/ss <path>` ready to send)
;   Ctrl+Alt+S    → trigger Win+Shift+S only (manual flow)
;   Ctrl+Alt+Shift+S → capture, save, copy PATH to clipboard, tray tip
;
; Install: install AutoHotkey v2 (https://www.autohotkey.com/), then double-click
; this file or drop a shortcut into shell:startup for autostart.

#Requires AutoHotkey v2.0
#SingleInstance Force

ScriptDir := A_ScriptDir
PSScript  := ScriptDir "\save-clipboard-image.ps1"

TriggerSnip() {
    Send("#+s")  ; Win+Shift+S
}

CaptureAndSave() {
    A_Clipboard := ""
    TriggerSnip()
    if !ClipWait(20, 2) {
        TrayTip("screenshot-paste", "No image captured within 20s.", 0x2)
        return ""
    }
    try {
        shell := ComObject("WScript.Shell")
        exec  := shell.Exec('powershell.exe -ExecutionPolicy Bypass -NoProfile -File "' PSScript '"')
        out   := exec.StdOut.ReadAll()
        path  := Trim(out, " `r`n`t")
        if path != "" && FileExist(path) {
            return path
        }
        TrayTip("screenshot-paste", "Helper returned no path.", 0x2)
    } catch as err {
        TrayTip("screenshot-paste", "Error: " err.Message, 0x2)
    }
    return ""
}

; Alt+Shift+S — capture + type "/ss <path> " into focused window
!+s:: {
    path := CaptureAndSave()
    if path = ""
        return
    ; Type slash command + path. User hits Enter to send.
    SendText("/ss " path " ")
}

; Ctrl+Alt+S — just trigger region capture
^!s::TriggerSnip()

; Ctrl+Alt+Shift+S — capture, save, copy path to clipboard
^!+s:: {
    path := CaptureAndSave()
    if path = ""
        return
    A_Clipboard := path
    TrayTip("screenshot-paste", "Saved: " path "`nPath copied to clipboard.", 0x1)
}
