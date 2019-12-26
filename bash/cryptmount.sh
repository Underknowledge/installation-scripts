#!/bin/bash
CONTAINER=${2-Container_X}
CONTAINER_MOUNT=$(echo "$CONTAINER_MOUNT" | awk '{ print toupper($0) }' | sed 's/_//g' | sed 's/-//g' )
TEMPMOUNT=$(pwd)/$CONTAINER_MOUNT
SIZE=$3
SIZE+=${4-MB}
COUNT=${2-16}
FILLCOUNT=${3-250}

create () {
fallocate -l $SIZE $CONTAINER  && echo "created an empty file" || { echo "there is an issue, You probably misspelled KB MB or GB"; exit 1; } 
cryptsetup -v luksFormat $CONTAINER  
read -p "Want to leave a password hint behind? 
will be saved under .pwhint_$CONTAINER
y/n? " -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]*$ ]]
then
    { read -p "your password hint: ";  echo "$REPLY" > .pwhint_$CONTAINER ; }
fi
sudo cryptsetup -v luksOpen $CONTAINER $CONTAINER_MOUNT 
sudo mkfs -t ext4 /dev/mapper/$CONTAINER_MOUNT  
mkdir -p $TEMPMOUNT  && \
sudo mount /dev/mapper/$CONTAINER_MOUNT $TEMPMOUNT  
}

mount(){
mkdir -p $TEMPMOUNT
sudo cryptsetup -v luksOpen $CONTAINER $CONTAINER_MOUNT
ls /dev/mapper/
sudo mount /dev/mapper/$CONTAINER_MOUNT $TEMPMOUNT
}

unmount(){
sudo umount $TEMPMOUNT && rm -r $TEMPMOUNT || echo "something went wrong while unmounting"
sudo cryptsetup luksClose $CONTAINER_MOUNT
}

fillfat (){
dd if=<(openssl enc -aes-256-ctr -pass pass:"$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64)" -nosalt < /dev/zero) of=$(pwd)/random_$RANDOM.bin bs=1M count=$FILLCOUNT iflag=fullblock
}

case "$1" in 
    create) echo " Usage: \$$0 create (NAME) (SIZE IN MB) (OVERWRITE MB to KB GB TB...)" ; sleep 3 ;  
    if [[ -f "$2" ]]; then
        echo "$2 such a file exist already.. pick another name! "
        exit 1
    fi
    if [[ -d "$2" ]]; then
        echo "$2 There is an directory in the way.. pick another name! "
        exit 1
    fi
    if [ -z "$3" ]; then
        echo "Something is missing. Usage: \$$0 create (NAME) (SIZE IN MB) (OVERWRITE MB to KB GB TB) "
    fi
    [ ! -z "${3##*[!0-9]*}" ] && echo "This will create a $SIZE crypt container" || { echo "You need to set a filesize "; exit 1; } 
    create
    ;;
    mount)     mount ;;
    unmount)   unmount ;;
    fill) echo "Usage: $0 fill (Count) (Size in MB) set to $(($COUNT*$FILLCOUNT))MB spread across $COUNT files"; sleep 3 ;
    for ((n=0;n<$COUNT;n++)); do echo $n && fillfat ; done ;;
    *) echo "usage: $0 mount|unmount|create|fill" >&2
       exit 1
       ;;
esac

:' 
The cryptmount shell file should help you carry around confidential data like SSH keys or customer data on a USB Stick. 
edit line #2 to your standard container to use ` $cryptmount.sh mount` or `unmount` allone without extra arguments.
`$cryptmount.sh create 100 ` will create an 100MB container and mount it afterwards. you could also run
`$cryptmount.sh create 800 GB ` to create an 800 GB container file. Feel free to commmit changes! 
when you had confidential files on a USB already you can fill the drive with `$cryptmount.sh fill ` Without arguments it will create 4GB of data.
to fill 8GB use for example `$cryptmount.sh fill 32 250 `
'
