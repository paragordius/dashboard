#!/bin/bash

set -e

packages='sudo vim htop rxvt-unicode x11vnc chromium chromium-l10n xorg openbox unclutter xdotool'

if [ -z "$(cat /etc/issue | grep "Debian GNU/Linux 8")" ]; then 
    echo "This script was only written to run on Debian Jessie. Exiting..."
    exit 1
fi

su -c "apt-get update && apt-get install $packages -y && adduser $USER sudo"
#su - $USER
#orig_group=$(id -g)
#newgrp sudo
#newgroup $orig_group
echo '#!/bin/bash

links=( $(cat links-to-load.txt | grep -v ^#) )

sed -i 's/"exited_cleanly":false/"exited_cleanly":true/g' $HOME/.config/chromium/Default/Preferences
xset s off &
xset -dpms &
x11vnc -nap -wait 30 -noxdamage -display :0 -forever &
unclutter -idle 1 -jitter 2 -root &
urxvt &
#chromium-browser \
chromium \
  --kiosk-mode \
  --auto-launch-at-startup \
  --disable-hang-monitor \
  --disable-session-crashed-bubble \
  --disable-cache \
  --disable-canvas-aa \
  --default-tile-width=384 \
  --default-tile-height=384 \
  $( echo ${links[@]} ) &
#xdotool search -sync -onlyvisible -class "chromium-browser" key F11
sleep 15 && xdotool search --onlyvisible --class "Chromium" windowfocus key 'F11' &
openbox-session' > ~/.xsession
echo 'if [ -z "$SSH_CLIENT" ] || [ -z "$SSH_TTY" ]; then
    startx
fi' >> ~/.bashrc
echo 'https://www.google.com/' > ~/links-to-load.txt
su -c "sed -i \"s/ExecStart.*/ExecStart=-\/sbin\/agetty -a $USER %I $TERM/g\" /etc/systemd/system/getty.target.wants/getty@tty1.service
systemctl set-default multi-user.target
reboot"