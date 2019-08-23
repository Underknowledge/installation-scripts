#!/bin/bash 
if (( $# == 0 )); then
    echo "No parameters provided you need to define an user and a group"
    exit1
else
    echo "you will add an user named $1 and add them to the group $2"
fi
echo "type yes to move on "
read
if [ "$REPLY" != "yes" ]; then
   exit
fi
sudo useradd -M $1 --shell /bin/false
sudo usermod -L $1
sudo usermod -a -G $2 $1
echo " at the moment the users $(sudo awk -F':' '$2 ~ "\$" {print $1}' /etc/shadow) are able to login "
