


` $ ssh-copy-id -i ~/.ssh/file.key.pub pi@[IP]` 

` $ sudo nano /etc/ssh/sshd_config ` 


**Banner** 

` $ sudo apt-get install figlet && figlet -c "XXXXYYYY" > ~/banner && echo "cat banner" >> ~/.bashrc ` 

**Cron jobs** 

` $ sudo crontab -e` 

` @reboot xy.sh `
