#!/bin/sh
sed '93 a alias bluetoothinfos='sudo btmon' ~/.bashrc 
sed '93 a alias fliclog='journalctl -u flicd -f'' ~/.bashrc 
sed '93 a alias fliclogs='tail -f /home/pi/flic/flic_log.txt'' ~/.bashrc 
sed '93 a alias simpleclient='/home/pi/simpleclient/simpleclient localhost'' ~/.bashrc 
