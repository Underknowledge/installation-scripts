#!/bin/bash
ipadress=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
echo "========================================================"
echo " This short script will disable password Authentication in the favour of keys  "
echo " when you dont have ssh-keys yet, I liked this article:"
echo "       https://www.ssh.com/ssh/keygen/ " 
echo    
echo   
echo  
echo " You can copy your key over with "
echo   
echo  
echo "\$ ssh-copy-id -i ~/.ssh/file.key.pub pi@${ipadress} "
echo "        (high Chances that you named your file diffrently) " 
echo "========================================================"
echo   
echo "type yes to move on "
read  
if [ "$REPLY" != "yes" ]; then
   exit
fi
if [[ -e "/etc/ssh/sshd_config_backup" ]]
then
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_backup_2
else
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_backup
fi

if [ -r ~/.ssh/authorized_keys ];
then
    echo "~/.ssh/authorized_keys exists and is readable"
else
    echo "~/.ssh/authorized_keys is not readable"
    sleep 2 
    echo lets try to chown ~/.ssh/authorized_keys - its meight be not here...
    sudo chown $USER:$USER ~/.ssh/authorized_keys
    exit 401
fi
echo   
echo " sorry that I'm aggravating, are you shure that you installed the key? "
echo " is it READABLE from the user you log in?" 
echo " type yes once more to move on "
read  
if [ "$REPLY" != "yes" ]; then
   exit
fi
echo "========================================================"
echo " OK! Lets do it! "
echo
echo
sudo sed -i 's/#PermitRootLogin\ prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config 
echo " PermitRootLogin no "
echo
sudo sed -i 's/#PubkeyAuthentication\ yes/PubkeyAuthentication\ yes/g' /etc/ssh/sshd_config
echo " uncomment PubkeyAuthentication "
echo
sudo sed -i 's/#MaxAuthTries.*/MaxAuthTries 3/g' /etc/ssh/sshd_config 
echo " MaxAuthTries 7 "
echo
sudo sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/g' /etc/ssh/sshd_config 
echo " uncomment AuthorizedKeysFile "
echo
sudo sed -i 's/#PasswordAuthentication\ yes/PasswordAuthentication\ no/g' /etc/ssh/sshd_config 
echo " PasswordAuthentication no"
echo
sudo service ssh reload
echo " reloading ssh service"
echo
echo "already finished!"
echo
echo "HAVE FUN!"
