# osRael

## Hyprpaper

To reload the configuration run `systemctl --user restart hyprpaper`

## Arduino-IDE

Install with `yay -S arduino-ide`.

Connect the board and check `ls -l /dev/ttyUSB0`. It should show the group (e.g. `uucp`). Then do `sudo usermod -aG <group> $USER`.
