#!/bin/bash 
if (( $# == 0 )); then
    echo "No parameters provided you need to define an user and a group"
    exit1
else
    echo "you will add an user named $1 and add them to the group $2"
    echo " to add a group run 'sudo groupadd -g <GID you like> <group>' "
fi
echo "type yes to move on "
read
if [ "$REPLY" != "yes" ]; then
   exit
fi
sudo useradd -M $1 --shell /bin/false
sudo usermod -L $1
sudo usermod -a -G $2 $1
echo
echo " at the moment the users 
echo " $(sudo awk -F':' '$2 ~ "\$" {print $1}' /etc/shadow) "
echo "are able to login "
echo
echo " $(id $1)"
echo
echo " after this script is thourght for the usage with docker containers run for example:
sudo chown -R $1:$2 $pwd "
