#!/bin/bash
hardware=$(uname -m)
ipadress=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
echo "
 
========================================================
This short script will install a flic systemd deamon on a Raspberry Pi 
https://github.com/50ButtonsEach/fliclib-linux-hci

========================================================"
echo 
case $(ps -p 1 -o comm=) in
    systemd)  echo "systemd check passed" && echo && echo  ;;
    *) echo "systemd check failed" && echo "sorry.. This script is intended for distros running systemd" && echo && exit 1 ;;
esac
echo 
read -n 1 -s -r -p "Press any key to continue"
echo 
echo "Downloading ${hardware}/flicd"
#  curl https://raw.githubusercontent.com/50ButtonsEach/fliclib-linux-hci/master/bin/armv6l/flicd > /usr/local/bin/flicd
case $(uname -m) in
    i386)    curl https://github.com/50ButtonsEach/fliclib-linux-hci/blob/master/bin/i386/flicd?raw=true > /usr/local/bin/flicd ;;
    x86_64)  curl https://github.com/50ButtonsEach/fliclib-linux-hci/blob/master/bin/x86_64/flicd > /usr/local/bin/flicd ;;
    armv6l)  curl https://raw.githubusercontent.com/50ButtonsEach/fliclib-linux-hci/master/bin/armv6l/flicd > /usr/local/bin/flicd ;;
    *) echo "Sorry, I can not get a $(uname -m) flic binary for you :(" && exit 1 ;;
esac
chmod a+x /usr/local/bin/flicd
echo "Downloading systemd file and make it executable"
curl https://raw.githubusercontent.com/Underknowledge/installation-scripts/pi-zero/flicd/flicd.service > /etc/systemd/system/flicd.service
chmod a+x /etc/systemd/system/flicd.service
echo "Disableing Bluetooth" 
sudo systemctl stop bluetooth
sudo systemctl disable bluetooth
echo "enabling the new flicd.service" 
sudo systemctl enable flicd.service
sudo systemctl start flicd.service
echo "creating the dir 

"
echo "setting up crontab" 
(sudo crontab -u root -l; echo "@reboot systemctl stop bluetooth" ) | sudo crontab -u root -
echo "creating resetflicdaemon alias"
sed -i "/ls -CF/ a alias resetflicdaemon='sudo systemctl stop flicd.service && sudo rm /var/flic.db && sudo reboot'" ~/.bashrc 
echo "


you can add the following 3 lines to your Home Assistant config to use this pi as flic server
========================================================
binary_sensor:
  - platform: flic
    host: ${ipadress}
========================================================


to pair a button just press it for +7 secconds
when you facing issues pairing, run 'resetflicdaemon' it will delete the database and reboot the pi"
echo
read -n 1 -s -r -p "Press any key to continue"
echo 
exec bash
exit 0
