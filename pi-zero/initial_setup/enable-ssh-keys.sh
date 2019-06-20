#!/bin/bash
ipadress=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
echo "========================================================"
echo " This short script will disable password Authentication in the favur of keys  "
echo " when you dont have ssh-keys yet I liked this article"
echo " https://www.ssh.com/ssh/keygen/ " 
echo " You can copy your key over with "
echo   
echo " \$ ssh-copy-id -i ~/.ssh/file.key.pub pi@${ipadress} "
echo " high Chances that you named your file diffrently " 
echo   
echo " type yes to move on "
read  
if [ "$REPLY" != "yes" ]; then
   exit
fi  
echo   
echo " sorry that I'm aggravating, are you shure that you installed the key? "
echo   
echo " type yes once more to move on "
read  
if [ "$REPLY" != "yes" ]; then
   exit
fi
echo "========================================================"
echo " OK! Lets do it! "
sudo sed -i 's/#PermitRootLogin\ prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config 
echo " PermitRootLogin no "
sudo sed -i 's/#PubkeyAuthentication\ yes/PubkeyAuthentication\ yes/g' /etc/ssh/sshd_config
echo " uncomment PubkeyAuthentication "
sudo sed -i 's/#MaxAuthTries.*/MaxAuthTries 3/g' /etc/ssh/sshd_config 
echo " MaxAuthTries 3 "
sudo sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/g' /etc/ssh/sshd_config 
echo " uncomment AuthorizedKeysFile "
sudo sed -i 's/#PasswordAuthentication\ yes/PasswordAuthentication\ no/g' /etc/ssh/sshd_config 
echo " PasswordAuthentication no"
echo
echo
echo "already finished!"
echo
echo "HAVE FUN!"
