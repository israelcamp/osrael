cd yay && ./install.sh && cd ..

mkdir -p ~/.config/yay
cat > ~/.config/yay/config.json <<'EOF'
{
  "sudoloop": true,
  "cleanAfter": true,
  "cleanMenu": true,
  "diffMenu": false,
  "answerclean": "All",
  "noconfirm": true
}
EOF

cd zsh && ./install.sh && ./setup.sh && cd ..
cd ghostty && ./install.sh && ./setup.sh && cd ..
cd hyprland && ./install.sh && ./setup.sh && cd ..
cd others && ./install.sh && ./setup.sh && cd ..
cd brave && ./install.sh && cd ..
cd grimblast && ./install.sh && cd ..
cd tlp && ./install.sh && ./setup.sh && cd ..
cd waybar && ./install.sh && ./setup.sh && cd ..
cd nvim && ./install.sh && ./setup.sh && cd ..
cd files && ./install.sh && cd ..
cd walker && ./install.sh && ./setup.sh && cd ..
cd yazi && ./install.sh && cd ..

rm ~/.config/yay/config.json
