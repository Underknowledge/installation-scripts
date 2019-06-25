

**Files for your fresh SD Card ** 


an other way: 
I renamed my file to ` buster-edit ` that I know wich ;) 

` $ fdisk -u -l 2019-06-20-raspbian-buster-edit.img ` 
``` 
Disk 2019-06-20-raspbian-buster-edit.img: 2 GiB, 2197815296 bytes, 4292608 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x0634f60c

Device                               Boot  Start     End Sectors  Size Id Type
2019-06-20-raspbian-buster-edit.img1        8192  532480  524289  256M  c W95 FAT3
2019-06-20-raspbian-buster-edit.img2      540672 4292607 3751936  1,8G 83 Linux
``` 
start (8192)*(512)= 4194304

`mount -o loop,offset=4194304 2019-06-20-raspbian-buster-edit.img /mnt/img_buster` 
add `ssh` and ` wpa_supplicant.conf` 
` $ umount /mnt/img_buster/ ` 



`mount -o loop,offset=276824064 2019-06-20-raspbian-buster-edit.img /mnt/img_buster`
I added ssh keys's, a secure ssh config, instalation scripts, some bashrc aliases and a useful bash history
`umount /mnt/img_buster/`
