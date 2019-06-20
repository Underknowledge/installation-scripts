#!/bin/sh
hardware=$(uname -m)
ipadress=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
if [ "${hardware}" != "armv6l" ]; then
   echo "sorry" && echo "this script is thought for raspberry pi's or other hardware running ${hardware} " && exit
fi
echo "========================================================"
echo "This short script will install a flic deamon on a Raspberry Pi "
echo "https://github.com/50ButtonsEach/fliclib-linux-hci" 
echo ""
echo "========================================================"
echo 
echo "type yes to move on "
read  
if [ "$REPLY" != "yes" ]; then
   exit
fi  
echo 
mkdir /home/pi/flic/
echo
echo "Downloading  armv6l/flicd "
curl https://raw.githubusercontent.com/50ButtonsEach/fliclib-linux-hci/master/bin/armv6l/flicd > /usr/local/bin/flicd
chmod a+x /usr/local/bin/flicd
echo
echo "Downloading  systemd file and make it executable "
curl https://raw.githubusercontent.com/Underknowledge/installation-scripts/pi-zero/flicd/flicd.service > /etc/systemd/system/flicd.service
chmod a+x /etc/systemd/system/flicd.service
echo
echo "Disableing Bluetooth" 
sudo systemctl stop bluetooth
sudo systemctl disable bluetooth
echo
echo " enabling the new flicd.service" 
sudo systemctl enable flicd.service
sudo systemctl start flicd.service
echo
echo
echo "creating the dir "
mkdir ~/simpleclient
echo
echo
echo "Downloading the sinple client" 
curl https://raw.githubusercontent.com/50ButtonsEach/fliclib-linux-hci/master/simpleclient/Makefile > ~/simpleclient/Makefile
curl https://raw.githubusercontent.com/50ButtonsEach/fliclib-linux-hci/master/simpleclient/simpleclient.cpp> ~/simpleclient/simpleclient.cpp
curl https://raw.githubusercontent.com/50ButtonsEach/fliclib-linux-hci/master/simpleclient/client_protocol_packets.h> ~/simpleclient/client_protocol_packets.h
echo "cd" 
cd simpleclient
echo "make" 
make
echo "make done!"
echo "cleaning up the setup files "
rm ~/simpleclient/Makefile
rm ~/simpleclient/simpleclient.cpp
rm ~/simpleclient/client_protocol_packets.h
echo "setting up crontab" 
(sudo crontab -u root -l; echo "@reboot systemctl stop bluetooth" ) | sudo crontab -u root -
echo "creating some aliases"
sed -i "/ls -CF/ a alias resetflicdaemon='sudo systemctl stop flicd.service && sudo rm /home/pi/flic/flic.sqlite3 && sudo reboot'" ~/.bashrc 
exec bash
echo "${ipadress} "
echo " run simpleclient with 'simpleclient` "
echo " Done " 
echo " check for errors with 'journalctl -u flicd -f'  the alias is `fliclog` "
echo " 'sudo btmon' for the actuall bt actions alias is `btinfo`"
echo " 'dmesg' for kernel errors - good luck "
