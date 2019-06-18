#!/bin/sh
mkdir /home/pi/flic/
echo ""
echo "Downloading  armv6l/flicd "
curl https://raw.githubusercontent.com/50ButtonsEach/fliclib-linux-hci/master/bin/armv6l/flicd > /usr/local/bin/flicd
chmod a+x /usr/local/bin/flicd
echo ""
echo "Downloading  systemd file and make it executable "
curl https://raw.githubusercontent.com/Underknowledge/installation-scripts/pi-zero/flicd/flicd.service > /etc/systemd/system/flicd.service
chmod a+x /etc/systemd/system/flicd.service
echo ""
echo "Disableing Bluetooth" 
sudo systemctl stop bluetooth
sudo systemctl disable bluetooth
echo ""
echo " enabling the new flicd.service" 
sudo systemctl enable flicd.service
sudo systemctl start flicd.service
echo ""
echo ""
echo "creating the dir "
mkdir ~/simpleclient
echo ""
echo ""
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
sed -i "/ls -CF/ a alias btinfo='sudo btmon'" ~/.bashrc 
sed -i "/ls -CF/ a fliclog='journalctl -u flicd -f'" ~/.bashrc 
sed -i "/ls -CF/ a fliclogs='tail -f /home/pi/flic/flic_log.txt'" ~/.bashrc 
sed -i "/ls -CF/ a alias simpleclient='/home/pi/simpleclient/simpleclient localhost'" ~/.bashrc 
sed -i "/ls -CF/ a alias flicstart='sudo systemctl start flicd.service'" ~/.bashrc 
sed -i "/ls -CF/ a alias flicstop='sudo systemctl stop flicd.service'" ~/.bashrc 
sed -i "/ls -CF/ a alias flicrestart='sudo systemctl restart flicd.service'" ~/.bashrc 
sed -i "/ls -CF/ a alias flicstatus='sudo systemctl status flicd.service'" ~/.bashrc 
exec bash
echo ""
echo "run simpleclient with 'simpleclient` "
echo " Done " 
echo " check for errors with 'journalctl -u flicd -f'  the alias is `fliclog` "
echo " 'sudo btmon' for the actuall bt actions alias is `btinfo`"
echo " 'dmesg' for kernel errors - good luck "
