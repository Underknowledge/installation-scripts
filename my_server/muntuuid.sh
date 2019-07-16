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
    
# do stuff here 


    exit 0
fi
