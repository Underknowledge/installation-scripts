#!/bin/bash
uuid=AAA0-FFF0
path=/media/usbxy

if mount | grep $(blkid -U "${uuid}") | grep "${path}" > /dev/null
then
    echo "

unmounting ${path}

 "
    sudo umount "${path}"
    echo " Done "

else
    echo "

couldn't find a mount in the filesystem
trying to mount to ${path}  

 "
    sudo mount $(blkid -U "${uuid}") "${path}"

# do stuff here like
#    sudo mv -v ${path}/Folder/ /share/HDD/xyz
# or rsync -az --delete /mnt/data/ /media/current_working_data/;
# or /usr/bin/rsync -a --delete -q /mnt/ha-config/ /ab/cd/$(date +"%A" -d "-1 day")/



    exit 0
fi
