
#!/bin/bash
echo " 
========================================================

This installs Mosquitto, git, and andrewjfreyer's Monitor without much cmd+c/v 


========================================================"
# get mosquitto repo key
wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
#add repo
sudo apt-key add mosquitto-repo.gpg.key
rm mosquitto-repo.gpg.key
#download appropriate lists file 
cd /etc/apt/sources.list.d/
sudo wget https://repo.mosquitto.org/debian/mosquitto-stretch.list
# sudo curl https://repo.mosquitto.org/debian/mosquitto-stretch.list > /etc/apt/sources.list.d/mosquitto-stretch.list
#update caches and install 
apt-cache search mosquitto
sudo apt-get update
sudo apt-get install -f libmosquitto-dev mosquitto mosquitto-clients libmosquitto1 git
cd ~
#clone andrewjfreyer's repo
git clone git://github.com/andrewjfreyer/monitor
#enter `monitor` directory
cd monitor/
echo " 

Monitor will start up now and set up the service file 


"
delay 3
sudo bash monitor.sh
