
#!/bin/bash
echo " 
========================================================

This installs Mosquitto, git, and andrewjfreyer's Monitor without much cmd+c/v 


========================================================"
echo "# get mosquitto repo key"
wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
echo "#add repo"
sudo apt-key add mosquitto-repo.gpg.key
rm mosquitto-repo.gpg.key
echo "#download appropriate lists file"
sudo wget -O /etc/apt/sources.list.d//mosquitto-$(lsb_release -cs).list https://repo.mosquitto.org/debian/mosquitto-$(lsb_release -cs).list
echo "#update caches and install"
apt-cache search mosquitto
sudo apt-get update
sudo apt-get install -f libmosquitto-dev mosquitto mosquitto-clients libmosquitto1 git bc bluez-hcidump -y
cd ~
echo "#clone andrewjfreyer's repo"
git clone git://github.com/andrewjfreyer/monitor
echo "#enter `monitor` directory"
cd monitor/
echo " 

Monitor will start up now and set up the service file 

"
delay 3
sudo bash /home/pi/monitor/monitor.sh

sudo nano /etc/systemd/system/monitor.service

sudo systemctl daemon-reload
sudo systemctl restart monitor.service 
