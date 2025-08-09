#  /usr/share/plymouth/themes => themes
#  /etc/plymouth/ => config
#
# need to add plymouth before encrypt in /etc/mkinitcpio.conf
# run sudo mkinitcpio -P
# 
# if grub then change /boot/grub/grub.cfg => NOT
# change /etc/default/grub to have 
# GRUB_CMDLINE_LINUX_DEFAULT=" quiet splash"
# sudo cp -r ~/osrael/plymouth/themes/osrael /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R osrael

# regenerat grub sudo grub-mkconfig -o /boot/grub/grub.cfg
