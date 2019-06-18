#!/bin/sh
sed -i "/ls -CF/ a alias bluetoothinfos='sudo btmon'" ~/.bashrc 
sed -i "/ls -CF/ a fliclog='journalctl -u flicd -f'" ~/.bashrc 
sed -i "/ls -CF/ a fliclogs='tail -f /home/pi/flic/flic_log.txt'" ~/.bashrc 
sed -i "/ls -CF/ a alias simpleclient='/home/pi/simpleclient/simpleclient localhost'" ~/.bashrc 
