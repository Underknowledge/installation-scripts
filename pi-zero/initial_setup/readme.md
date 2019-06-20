
 `sudo raspi-config`
 
 - `Change User Password`  
 - `Network Options/Hostname` 
 - `Boot Options/B2 Wait for Network at Boot` 
 - `Advanced Options/A1 Expand Filesystem`
 
 instead of updating with the raspi-config script I like to run: 
 `sudo apt-get update && sudo apt-get upgrade -y && sudo reboot` 
