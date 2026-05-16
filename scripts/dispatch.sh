#!/usr/bin/env bash
# Cross-platform dispatch. Picks PowerShell on Windows (Git Bash / WSL with PS available),
# otherwise the POSIX clipboard reader.
set -euo pipefail

dir="$(cd "$(dirname "$0")" && pwd)"

case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
        powershell.exe -ExecutionPolicy Bypass -File "$(cygpath -w "$dir/save-clipboard-image.ps1")"
        ;;
    *)
        bash "$dir/save-clipboard-image.sh"
        ;;
esac
