#!/bin/sh
sed -i "/ls -CF/ a alias btinfo='sudo btmon'" ~/.bashrc 
sed -i "/ls -CF/ a fliclog='journalctl -u flicd -f'" ~/.bashrc 
sed -i "/ls -CF/ a fliclogs='tail -f /home/pi/flic/flic_log.txt'" ~/.bashrc 
sed -i "/ls -CF/ a alias simpleclient='/home/pi/simpleclient/simpleclient localhost'" ~/.bashrc 
sed -i "/ls -CF/ a alias startflic='sudo systemctl start flicd.service'" ~/.bashrc 
sed -i "/ls -CF/ a alias stopflic='sudo systemctl stop flicd.service'" ~/.bashrc 
sed -i "/ls -CF/ a alias restartflic='sudo systemctl restart flicd.service'" ~/.bashrc 
sed -i "/ls -CF/ a alias enableflic='sudo systemctl enable flicd.service'" ~/.bashrc 
sed -i "/ls -CF/ a alias disableflic='sudo systemctl disable flicd.service'" ~/.bashrc 
sed -i "/ls -CF/ a alias flickill='sudo systemctl stop flicd.service && sudo rm /home/pi/flic/flic.sqlite3 && sudo reboot'" ~/.bashrc 
exec bash
