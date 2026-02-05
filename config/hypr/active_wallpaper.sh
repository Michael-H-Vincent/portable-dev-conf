# #!/bin/bash
set -euo pipefail

# Directory containing your wallpapers (set this to your folder)
CWD="$(pwd)"
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers/wallpaper_cycle"

# Monitor name (change if needed, e.g. DP-1, HDMI-A-1, etc.)
MONITOR=""

# Pick a random image from the directory (common formats)
WALLPAPER="$(find "$WALLPAPER_DIR" -type f \( \
    -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
\) -print0 | shuf -z -n 1 | tr -d '\0')"

# Bail if nothing found
if [[ -z "${WALLPAPER:-}" ]]; then
  echo "No wallpapers found in: $WALLPAPER_DIR" >&2
  exit 1
fi

# Preload and set the wallpaper
echo 1
hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER"
echo 2

