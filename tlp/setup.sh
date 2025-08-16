sudo systemctl enable tlp --now
sudo systemctl stop power-profiles-daemon.service
sudo systemctl mask power-profiles-daemon.service
sudo systemctl restart tlp
tlp-stat -s
