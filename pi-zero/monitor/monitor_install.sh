#!/bin/bash
DIR="/home/pi/monitor"
echo "
========================================================

This installs Mosquitto, git, and andrewjfreyer's Monitor without much cmd+c/v


========================================================"


sleep 1

if [ -d "$DIR" ]
then
        echo "$DIR directory  exists!"
        echo
        echo " adding flags

             -b for BLE beacons
             -x for retained messages
             "
        sleep 3
        sudo nano /etc/systemd/system/monitor.service


# ExecStart=/bin/bash /home/pi/monitor/monitor.sh  &
# to
# ExecStart=/bin/bash /home/pi/monitor/monitor.sh -b -x &


        sudo systemctl daemon-reload
        echo "Daemon reloaded"
        sudo systemctl restart monitor.service
        echo "Monitor restarted"
else
        echo "$DIR directory not found! Starting to download"
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
        sleep 3
        sudo bash /home/pi/monitor/monitor.sh

fi
sleep 1
echo "DONE"
journalctl -u monitor -f
