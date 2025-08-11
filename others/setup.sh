#!/usr/bin/env bash

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Set global Git user.name and user.email (works in bash and zsh)
set -u

# Ensure git is available
if ! command -v git >/dev/null 2>&1; then
  printf "Error: git is not installed or not in PATH.\n" >&2
  exit 1
fi

# Read current values if any
current_name="$(git config --global user.name 2>/dev/null || printf "")"
current_email="$(git config --global user.email 2>/dev/null || printf "")"

prompt_with_default() {
  # $1: label, $2: default; result in REPLY
  local label="$1" default="$2" input
  while :; do
    if [ -n "$default" ]; then
      printf "%s [%s]: " "$label" "$default"
    else
      printf "%s: " "$label"
    fi
    IFS= read -r input
    if [ -n "$input" ]; then
      REPLY="$input"
      return 0
    elif [ -n "$default" ]; then
      REPLY="$default"
      return 0
    fi
    printf "Value cannot be empty. Try again.\n"
  done
}

valid_email() {
  # Minimal sanity check: exactly one '@', at least one dot after it, no spaces
  case "$1" in
    ""|*" "*) return 1 ;;
  esac
  local rest="${1#*@}"
  [ "$rest" = "$1" ] && return 1          # no '@'
  [ "${rest#*@}" != "$rest" ] && return 1 # more than one '@'
  case "$rest" in *.*) return 0 ;; *) return 1 ;; esac
}

# Gather inputs
prompt_with_default "Enter Git user name" "$current_name"
name="$REPLY"

while :; do
  prompt_with_default "Enter Git email" "$current_email"
  email="$REPLY"
  if valid_email "$email"; then
    break
  else
    printf "That doesn't look like a valid email. Please try again.\n"
  fi
done

# Confirm
printf "\nAbout to set:\n  user.name  = %s\n  user.email = %s\n" "$name" "$email"
printf "Proceed? [y/N]: "
read -r yn
case "${yn:-N}" in
  [yY]|[yY][eE][sS]) ;;
  *) printf "Aborted.\n"; exit 1 ;;
esac

# Apply settings
if git config --global user.name "$name" \
   && git config --global user.email "$email"; then
  printf "Done! Global Git identity is now:\n"
  printf "  user.name  = %s\n" "$(git config --global user.name)"
  printf "  user.email = %s\n" "$(git config --global user.email)"
else
  printf "Failed to update global Git config.\n" >&2
  exit 1
fi
