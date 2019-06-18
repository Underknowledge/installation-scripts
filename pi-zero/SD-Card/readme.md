

**WIP** 
` $ ssh-copy-id -i ~/.ssh/file.key.pub pi@[IP]` 

` $ sudo nano /etc/ssh/sshd_config ` 


sudo sed -i -e 's/#AuthorizedKeysFile/AuthorizedKeysFile/g' /etc/ssh/sshd_config 
sudo sed -i -e 's/#PasswordAuthentication\ yes/PasswordAuthentication\ no/g' /etc/ssh/sshd_config 
sudo sed -r 's/#PermitRootLogin\ prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config 




sed "s/.*RSAAuthentication.*/RSAAuthentication yes/g" sshd_config
sed "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" sshd_config
sed  "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" sshd_config
sed  "s/.*AuthorizedKeysFile.*/AuthorizedKeysFile\t\.ssh\/authorized_keys/g" sshd_config
sed  "s/.*PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config







**Banner** 

` $ sudo apt-get install figlet && figlet -c "XXXXYYYY" > ~/banner && echo "cat banner" >> ~/.bashrc ` 

**Cron jobs** 

` $ sudo crontab -e` 

` @reboot xy.sh `
