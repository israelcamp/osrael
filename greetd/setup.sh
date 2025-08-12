#!/usr/bin/env bash


set -euo pipefail

CONFIG="${HOME}/osrael/greetd/config/config.toml"

read -r -p "Do you want to enable auto-login via [initial_session]? [y/N] " ans
case "${ans:-}" in
  y|Y|yes|YES) ENABLE_AUTOLOGIN=1 ;;
  *) ENABLE_AUTOLOGIN=0; echo "Auto-login not enabled; continuing..." ;;
esac

USER_NAME=$USER
SESSION_CMD="Hyprland"

# Escape for TOML double-quoted strings
escape_toml() {
  # escape backslashes and double quotes
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}
USER_ESC="$(escape_toml "$USER_NAME")"
CMD_ESC="$(escape_toml "$SESSION_CMD")"

if [ "$ENABLE_AUTOLOGIN" -eq 1 ]; then
  # Append the new block
  {
    echo
    echo "[initial_session]"
    echo "command = \"${CMD_ESC}\""
    echo "user = \"${USER_ESC}\""
  } >> "$CONFIG"

  echo "Wrote [initial_session] to $CONFIG:"
  printf '\n%s\n' "[initial_session]
command = \"${SESSION_CMD}\"
user = \"${USER_NAME}\""
else
  echo "Skipped writing [initial_session]."
fi

echo
echo "Done. (Tip: keep a [default_session] greeter for after logout.)"

sudo rm -rf /etc/greetd/
sudo cp -r ~/osrael/greetd/config/ /etc/greetd
sudo cp -r ~/osrael/hyprland/wallpapers/ /usr/share/wallpapers
sudo systemctl enable greetd.service

