#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$REPO_DIR/config"

echo "========================================"
echo "  Frutiger Aero — Omarchy Theme Install"
echo "========================================"

# ── Global configs ──────────────────────────────────────────

echo ":: Installing global configs..."

# Waybar
echo "   → waybar/"
mkdir -p ~/.config/waybar/scripts
cp "$CONFIG_DIR/waybar/style.css" ~/.config/waybar/style.css
cp "$CONFIG_DIR/waybar/config.jsonc" ~/.config/waybar/config.jsonc
for f in "$CONFIG_DIR/waybar/scripts/"*.sh; do
  cp "$f" ~/.config/waybar/scripts/
  chmod +x ~/.config/waybar/scripts/"$(basename "$f")"
done
# Copy shared libraries
[ -d "$REPO_DIR/scripts" ] && cp "$REPO_DIR/scripts/"*.sh ~/.config/waybar/scripts/

# Remove waybar scripts that this repo previously shipped but no longer
# includes (e.g. caffeine.sh, pomodoro.sh, playerctl-cover.sh removed in #12,
# audio-eq.sh). Only targets known historical names — user-installed scripts
# are left alone.
STALE_SCRIPTS="caffeine.sh pomodoro.sh playerctl-cover.sh audio-eq.sh"
for name in $STALE_SCRIPTS; do
  if [ -f ~/.config/waybar/scripts/"$name" ] && [ ! -f "$CONFIG_DIR/waybar/scripts/$name" ]; then
    rm ~/.config/waybar/scripts/"$name"
    echo "   → removing stale waybar script: $name"
  fi
done

# Hyprland
echo "   → hypr/"
mkdir -p ~/.config/hypr
# Preserve user's existing input.lua (keyboard layout) and monitors.lua (monitor config)
if [ -f ~/.config/hypr/input.lua ]; then
  ts="$(date +%s)"
  cp ~/.config/hypr/input.lua ~/.config/hypr/input.lua.bak."$ts"
  echo "   → preserved existing input.lua (keyboard layout)"
fi
if [ -f ~/.config/hypr/monitors.lua ]; then
  ts="$(date +%s)"
  cp ~/.config/hypr/monitors.lua ~/.config/hypr/monitors.lua.bak."$ts"
  echo "   → preserved existing monitors.lua (monitor config)"
fi
cp "$CONFIG_DIR/hypr/"* ~/.config/hypr/
# Restore preserved files if they existed
for f in ~/.config/hypr/input.lua.bak.*; do
  [ -f "$f" ] && mv "$f" ~/.config/hypr/input.lua && echo "   → restored your keyboard layout" && break
done
for f in ~/.config/hypr/monitors.lua.bak.*; do
  [ -f "$f" ] && mv "$f" ~/.config/hypr/monitors.lua && echo "   → restored your monitor config" && break
done

# Alacritty
echo "   → alacritty/"
mkdir -p ~/.config/alacritty
cp "$CONFIG_DIR/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml

# Fontconfig
echo "   → fontconfig/"
mkdir -p ~/.config/fontconfig
cp "$CONFIG_DIR/fontconfig/fonts.conf" ~/.config/fontconfig/fonts.conf

# GTK
echo "   → gtk/"
mkdir -p ~/.config/gtk-3.0
cp "$CONFIG_DIR/gtk/settings.ini" ~/.config/gtk-3.0/settings.ini

# Helix
echo "   → helix/"
mkdir -p ~/.config/helix
cp "$CONFIG_DIR/helix/config.toml" ~/.config/helix/config.toml

# Fastfetch
echo "   → fastfetch/"
mkdir -p ~/.config/fastfetch
cp "$CONFIG_DIR/fastfetch/config.jsonc" ~/.config/fastfetch/config.jsonc




# ── EWW Widgets ─────────────────────────────────────────────

echo ""
echo ":: Installing EWW widgets..."

EWW_DIR="$REPO_DIR/eww"
if [ -d "$EWW_DIR" ]; then
  mkdir -p ~/.config/eww/assets/icons ~/.config/eww/scripts
  cp "$EWW_DIR/eww.yuck" ~/.config/eww/eww.yuck
  cp "$EWW_DIR/eww-dark.scss" ~/.config/eww/eww-dark.scss
  cp "$EWW_DIR/eww-light.scss" ~/.config/eww/eww-light.scss
  ln -sf ~/.config/eww/eww-dark.scss ~/.config/eww/eww.scss
  for f in "$EWW_DIR/scripts/"*; do
    [ -f "$f" ] && cp "$f" ~/.config/eww/scripts/
  done
  # Copy shared libraries
  [ -d "$REPO_DIR/scripts" ] && cp "$REPO_DIR/scripts/"*.sh ~/.config/eww/scripts/
  chmod +x ~/.config/eww/scripts/*.sh
  [ -d "$EWW_DIR/assets" ] && cp -r "$EWW_DIR/assets/"* ~/.config/eww/assets/
  echo "   → eww/ (weather, clock, calendar, music, sysmon, control panel)"
else
  echo "   → eww/ not found — skipping widgets"
fi

# ── Omarchy theme files ─────────────────────────────────────

echo ""
echo ":: Installing Omarchy themes..."

# The light theme lives in its own repository, which holds only theme files.
THEME_REPO="https://github.com/VECTORG99/omarchy-frutiger-aero"
LIGHT_DST=~/.config/omarchy/themes/frutiger-aero
if command -v omarchy-theme-install &>/dev/null; then
  # Installs and applies it, the same way the omarchy.org/themes route does.
  omarchy-theme-install "$THEME_REPO"
elif [ ! -d "$LIGHT_DST" ]; then
  git clone --depth 1 "$THEME_REPO" "$LIGHT_DST"
fi
echo "   → frutiger-aero"

# Dark variant ships with these extras.
DARK_SRC="$CONFIG_DIR/omarchy/themes/frutiger-aero-dark"
DARK_DST=~/.config/omarchy/themes/frutiger-aero-dark
if [ -d "$DARK_SRC" ]; then
  mkdir -p "$DARK_DST"
  cp -r "$DARK_SRC"/* "$DARK_DST/"
  echo "   → frutiger-aero-dark"
fi

# ── Omarchy hooks ───────────────────────────────────────────

echo ""
echo ":: Installing Omarchy hooks..."

HOOK_SRC="$CONFIG_DIR/omarchy/hooks"
HOOK_DST=~/.config/omarchy/hooks
if [ -d "$HOOK_SRC" ]; then
  mkdir -p "$HOOK_DST/theme-set.d"
  for f in "$HOOK_SRC"/theme-set.d/*; do
    [ -f "$f" ] || continue
    cp "$f" "$HOOK_DST/theme-set.d/"
    chmod +x "$HOOK_DST/theme-set.d/$(basename "$f")"
    echo "   → theme-set.d/$(basename "$f")"
  done
else
  echo "   → hooks/ not found — skipping"
fi

# ── Apply theme ─────────────────────────────────────────────

echo ""
if command -v omarchy &>/dev/null; then
  echo ":: Applying Frutiger Aero theme..."
  omarchy theme set "Frutiger Aero" 2>/dev/null || echo "   (theme set command timed out — run manually: omarchy theme set \"Frutiger Aero\")"
else
  echo ":: omarchy not found — copy theme files manually:"
  echo "     cp -r ~/.config/omarchy/themes/frutiger-aero/* ~/.config/omarchy/current/theme/"
fi

# ── Reload ──────────────────────────────────────────────────

echo ""
echo ":: Reloading Hyprland and restarting Waybar..."
hyprctl reload 2>/dev/null || true
omarchy-restart-waybar 2>/dev/null || true

echo ""
echo "========================================"
echo "  Done! Frutiger Aero is installed."
echo "========================================"
echo ""
echo "To switch themes:  omarchy theme set \"Frutiger Aero\""
echo "                   omarchy theme set \"Frutiger Aero Dark\""
echo ""
echo "To reload SDDM:    sudo omarchy-refresh-sddm"
