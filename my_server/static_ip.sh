#!/bin/bash
eth_interface=$(ls /sys/class/net | grep enp) 
eth_interface_v2=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")
echo "========================================================"
echo "    This short script will set the network interface from DHCP to static "
echo " "
echo " " 
echo " "
echo "https://wiki.debian.org/NetworkConfiguration" 
echo
echo "you can get your original configuation with: "
echo "sudo cp /etc/network/interfaces_backup /etc/network/interfaces"
echo
echo "========================================================"
echo
echo "type yes to move on "
read
if [ "$REPLY" != "yes" ]; then
   exit
fi
sudo cp /etc/network/interfaces /etc/network/interfaces_backup
sudo sed -i "s=iface $(ls /sys/class/net | grep enp) inet dhcp=iface $(ls /sys/class/net | grep enp) inet static=g" /etc/network/interfaces
sudo sed -i "/iface $(ls /sys/class/net | grep enp) inet static/ a \ \ \ \ \ \ \ \ gateway 10.0.0.1" /etc/network/interfaces
sudo sed -i "/iface $(ls /sys/class/net | grep enp) inet static/ a \ \ \ \ \ \ \ \ netmask 255.255.255.0" /etc/network/interfaces
sudo sed -i "/iface $(ls /sys/class/net | grep enp) inet static/ a \ \ \ \ \ \ \ \ address 10.0.0.27" /etc/network/interfaces
echo "========================================================"
echo "        we will be back in a short moment !  "
echo "========================================================"
sudo service networking restart
sudo ifup $(ls /sys/class/net | grep enp)
sleep 10
echo
echo "========================================================"
echo "should be done now I ll send you to the file to check it now"
echo "========================================================"
sleep 5
sudo nano /etc/network/interfaces
