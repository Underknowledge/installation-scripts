#!/bin/bash
uuid=AAA0-FFF0
path=/media/usbxy

rootId=$(stat -c%d /)
mountId=$(stat -c%d "${path}")

if (( rootId == mountId ))
then
   # code for not mounted
   echo "

   couldn't find a mount in the filesystem
   trying to mount to ${path}

   "
   sudo mount $(sudo blkid -U "${uuid}") "${path}"
   
# do stuff here like
#    sudo mv -v ${path}/Folder/ /share/HDD/xyz
# or rsync -az --delete /mnt/data/ /media/current_working_data/;
# or /usr/bin/rsync -a --delete -q /mnt/ha-config/ /ab/cd/$(date +"%A" -d "-1 day")/

else
   # code for mounted
   echo "

   unmounting ${path}

   "
   lsof | grep "${path}"
   sudo umount "${path}"
fi



