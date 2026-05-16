#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${OUT_DIR:-${TMPDIR:-/tmp}/claude-screenshots}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"

mkdir -p "$OUT_DIR"

if [[ "$RETENTION_DAYS" -gt 0 ]]; then
    find "$OUT_DIR" -maxdepth 1 -type f -name 'ss-*' -mtime "+${RETENTION_DAYS}" -delete 2>/dev/null || true
fi

ts=$(date +%Y%m%d-%H%M%S-%3N 2>/dev/null || date +%Y%m%d-%H%M%S)
out="$OUT_DIR/ss-$ts.png"

os="$(uname -s)"

case "$os" in
    Darwin)
        if ! command -v pngpaste >/dev/null 2>&1; then
            echo "pngpaste not installed. Run: brew install pngpaste" >&2
            exit 1
        fi
        if ! pngpaste "$out" 2>/dev/null; then
            echo "No image on clipboard." >&2
            exit 1
        fi
        ;;
    Linux)
        if [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-paste >/dev/null 2>&1; then
            if ! wl-paste --type image/png > "$out" 2>/dev/null || [[ ! -s "$out" ]]; then
                rm -f "$out"
                echo "No image on Wayland clipboard." >&2
                exit 1
            fi
        elif command -v xclip >/dev/null 2>&1; then
            if ! xclip -selection clipboard -t image/png -o > "$out" 2>/dev/null || [[ ! -s "$out" ]]; then
                rm -f "$out"
                echo "No image on X clipboard." >&2
                exit 1
            fi
        else
            echo "Install wl-clipboard (Wayland) or xclip (X11)." >&2
            exit 1
        fi
        ;;
    *)
        echo "Unsupported OS: $os" >&2
        exit 1
        ;;
esac

echo "$out"
