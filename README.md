# osRael

## Hyprpaper

To reload the configuration run `systemctl --user restart hyprpaper`

## Arduino-IDE

Install with `yay -S arduino-ide`.

Connect the board and check `ls -l /dev/ttyUSB0`. It should show the group (e.g. `uucp`). Then do `sudo usermod -aG <group> $USER`.

## Burning ISO

Run:

```bash

sudo dd if=<iso-path> of=<usb-path> bs=4M status=progress conv=fsync

```

Usually `usb-path=/dev/sdb`

## Avoid turninf off when closing lid

```bash

systemd-inhibit --what=handle-lid-switch sleep 1d`

```

You can change the value for sleep, e.g. 2d, 7d, etc..
