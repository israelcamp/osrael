# osRael

## Arduino-IDE

Install with `yay -S arduino-ide`.

Connect the board and check `ls -l /dev/ttyUSB0`. It should show the group (e.g. `uucp`). Then do `sudo usermod -aG <group> $USER`.
