#!/bin/bash
DIR="/home/pi/monitor"
mqtt_address="IP"
mqtt_user="monitor"
mqtt_password="PASS"
mqtt_publisher_identity="'monitor1'"
mqtt_port="'1883'"
mqtt_version="'mqttv311'"
echo "
========================================================

This installs Mosquitto, git, and andrewjfreyer's Monitor without much cmd+c/v


========================================================"


sleep 1

if [ -d "/home/pi/monitor" ]
then
        echo "The Monitor directory  exists already "
        echo
        echo " adding flags

             -b for BLE beacons
             -x for retained MQTT messages

             "
        sleep 3
        sudo sed -i "/monitor.sh\ \ &/c ExecStart=/bin/bash /home/pi/monitor/monitor.sh -b -x &" /etc/systemd/system/monitor.service
        cat /etc/systemd/system/monitor.service
        echo "
        
        adding mqtt settings 
        
        "
        sleep 3
        
        sudo sed -i "/mqtt_address=/c mqtt_address=$mqtt_address" /home/pi/monitor/mqtt_preferences
        sudo sed -i "/mqtt_user=/c mqtt_user=$mqtt_user" /home/pi/monitor/mqtt_preferences
        sudo sed -i "/mqtt_password=/c mqtt_password=$mqtt_password" /home/pi/monitor/mqtt_preferences
        sudo sed -i "/mqtt_publisher_identity=/c mqtt_publisher_identity=$mqtt_publisher_identity" /home/pi/monitor/mqtt_preferences
        sudo sed -i "/mqtt_port=/c mqtt_port=$mqtt_port" /home/pi/monitor/mqtt_preferences
        sudo sed -i "/mqtt_version=/c mqtt_version=$mqtt_version" /home/pi/monitor/mqtt_preferences
########
        sed "/# ---------------------------/ a 00:00:00:00:00:10 Bluetooth_beacon" /home/pi/monitor/known_beacon_addresses
########
        sed "/# ---------------------------/ a 00:00:00:00:00:10 Bluetooth_static" /home/pi/monitor/known_static_addresses
        
        
        sudo systemctl daemon-reload
        echo "Daemon reloaded"
        sudo systemctl restart monitor.service
        echo "Monitor restarted"
else
        echo "The Monitor directory was'nt found! Starting to download"
        echo "# get mosquitto repo key"
        echo
        wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
        echo "#add repo"
        echo
        sudo apt-key add mosquitto-repo.gpg.key
        rm mosquitto-repo.gpg.key
        echo "#download appropriate lists file"
        echo
        sudo wget -O /etc/apt/sources.list.d//mosquitto-$(lsb_release -cs).list https://repo.mosquitto.org/debian/mosquitto-$(lsb_release -cs).list
        echo "#update caches and install"
        apt-cache search mosquitto
        sudo apt-get update
        sudo apt-get install -f libmosquitto-dev mosquitto mosquitto-clients libmosquitto1 git bc bluez-hcidump -y
        cd ~
        echo "#clone andrewjfreyer's repo"
        git clone git://github.com/andrewjfreyer/monitor

        echo "
        Monitor will start up now and set up the service file
        install the service and cmd+c out of it and run this script again 
        "
        sleep 3
        cd /home/pi/monitor/
        sudo /home/pi/monitor/monitor.sh

fi
sleep 1
echo "DONE"
journalctl -u monitor -f
