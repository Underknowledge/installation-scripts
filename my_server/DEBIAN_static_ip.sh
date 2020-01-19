#!/bin/bash
eth_interface=$(ls /sys/class/net | grep enp| head -1)
address=$"10.0.0.28"
netmask=$"255.255.252.0"
gateway=$"10.0.0.1"
cfg=/etc/network/interfaces
if grep -qF "Otherwise edit the file:" /etc/network/interfaces
then
  echo "running this again is dangerus!, goodbye"
  echo 
  echo "cfg file youre looking for: /etc/network/interfaces" 
  exit 0
fi
echo "========================================================"
echo "    This short script will set the network interface  "
echo "    $eth_interface  from DHCP to static "
echo
echo "the current settings are:"
echo "address: $address "
echo "netmask: $netmask"
echo "gateway: $gateway"
echo
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
sudo apt install dnsutils -y

if [[ -e "/etc/network/interfaces_backup" ]]
then
    sudo cp /etc/network/interfaces /etc/network/interfaces_backup_2
else
    sudo cp /etc/network/interfaces /etc/network/interfaces_backup
fi
sudo sed -i "s=iface $eth_interface inet dhcp=iface $eth_interface inet static=g" $cfg || exit 0
sudo sed -i "/iface $eth_interface inet static/ a \ \ \ \ \ \ \ \ gateway $gateway" $cfg || exit 0
sudo sed -i "/iface $eth_interface inet static/ a \ \ \ \ \ \ \ \ netmask $netmask" $cfg || exit 0
sudo sed -i "/iface $eth_interface inet static/ a \ \ \ \ \ \ \ \ address $address" $cfg || exit 0
sudo sed -i "/gateway $gateway/ a #DNS configurations - only If resolvconf is installed" $cfg
sudo sed -i "/#DNS configurations - only If resolvconf is installed/ a # check with 'dpkg -l | grep resolvconf' " $cfg
sudo sed -i "/# check with 'dpkg -l | grep resolvconf'/ a # Otherwise edit the file:'/etc/resolv.conf' #dns-nameservers 1.1.1.1 " $cfg

echo "========================================================"
echo "        we will be back in a short moment !  "
echo "========================================================"
sudo service networking restart
sudo ifup $eth_interface
sleep 5
echo
echo "running 'dig home-assistant.io'"
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
