
 `sudo raspi-config`
 
 - `Change User Password`  
 - `Network Options/Hostname` 
 - `Boot Options/B2 Wait for Network at Boot` 
 - `Advanced Options/A1 Expand Filesystem`
 
 instead of updating with the raspi-config script I like to run: 
 `sudo apt-get update && sudo apt-get upgrade -y && sudo reboot` 

after your pi is restarted you can login with your new set password and run this 3 to 4 commands. 
``` 
  $ curl 
https://raw.githubusercontent.com/Underknowledge/installation-scripts/master/pi-zero/initial_setup/enable-ssh-keys.sh > ~/enable-ssh-keys.sh
  $ sudo chmod +x ~/enable-ssh-keys.sh
  $ cd ~
  $ ./enable-ssh-keys.sh
``` 




**Banner** 

` $ sudo apt-get install figlet && figlet -c "XXXXYYYY" > ~/banner && echo "cat banner" >> ~/.bashrc ` 



**Cron jobs** 

` $ sudo crontab -e` 

` @reboot xy.sh `
