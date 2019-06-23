#!/bin/bash
eth_interface=$(ls /sys/class/net | grep enp)
address=$"10.0.0.27"
netmask=$"255.255.255.0"
gateway=$"10.0.0.1"
echo "========================================================"
echo "    This short script will set the network interface  "
echo "    $eth_interface  from DHCP to static "
echo
echo "the current settings are:"
echo "address: $address "
echo "netmask: $netmask"
echo "gateway: $gateway"
echo
echo "https://wiki.debian.org/NetworkConfiguration"
echo
echo "of cause I find an easy to follow writeup when I'm finished..."
echo "https://medium.com/@cpt_midnight/static-ip-in-debian-9-stretch-acb4e5cb7dc1 "
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
sudo sed -i "s=iface $eth_interface inet dhcp=iface $(ls /sys/class/net | grep enp) inet static=g" /etc/network/interfaces
sudo sed -i "/iface $eth_interface inet static/ a \ \ \ \ \ \ \ \ gateway $gateway" /etc/network/interfaces
sudo sed -i "/iface $eth_interface inet static/ a \ \ \ \ \ \ \ \ netmask $netmask" /etc/network/interfaces
sudo sed -i "/iface $eth_interface inet static/ a \ \ \ \ \ \ \ \ address $address" /etc/network/interfaces
sudo sed -i "/gateway 10.0.0.1/ a #DNS configurations - only If resolvconf is installed" /etc/network/interfaces
sudo sed -i "/#DNS configurations - only If resolvconf is installed/ a # check with 'dpkg -l | grep resolvconf' " /etc/network/interfaces
sudo sed -i "/# check with 'dpkg -l | grep resolvconf'/ a # Otherwise edit the file:'/etc/resolv.conf' " /etc/network/interfaces
sudo sed -i "/# Otherwise edit the file:'/etc/resolv.conf' / a #dns-nameservers 1.1.1.1" /etc/network/interfaces
echo "========================================================"
echo "        we will be back in a short moment !  "
echo "========================================================"
sudo service networking restart
sudo ifup $(ls /sys/class/net | grep enp)
sleep 5
echo
echo "running `dig home-assistant.io'"
dig home-assistant.io
sleep 5
echo "running 'nslookup home-assistant.io'"
nslookup home-assistant.io
sleep 5
echo "========================================================"
echo "should be done now I ll send you to the file to check it now"
echo "========================================================"
sleep 5
sudo nano /etc/network/interfaces
