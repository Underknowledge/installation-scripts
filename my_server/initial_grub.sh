#!/bin/bash
GRUB_ALIENWARE="initcall_blacklist=dw_i2c_init_driver"
GRUB=/etc/default/grub
GRUB_=/etc/default/grub_bu

alienware () {
echo ""&& echo "lets blacklist $GRUB_ALIENWARE in $GRUB" && echo ""
if grep -qF "$GRUB_ALIENWARE" $GRUB
then
  echo "this parameter is already set, goodbye"
  exit 0
fi
sleep 1
echo "     from:"
sed --quiet 's#^\(GRUB_CMDLINE_LINUX_DEFAULT="\)#GRUB_CMDLINE_LINUX_DEFAULT="#p' $GRUB
echo "     to:"
sed --quiet 's#^\(GRUB_CMDLINE_LINUX_DEFAULT="\)#\1'$GRUB_ALIENWARE' #p' $GRUB
sleep 2
  read -r -p "Are You Sure? [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
    		echo "Yes"
    		;;
        [nN][oO]|[nN])
    		echo "No, Ok! bye"
            exit 1
           		;;
        *)
    	echo "Invalid input..."
    	exit 1
    	;;
    esac
sudo sed -i 's#^\(GRUB_CMDLINE_LINUX_DEFAULT="\)#\1'$GRUB_ALIENWARE' #' $GRUB
sudo update-grub
}



A1286 () {
echo "Patience, maybe later"
echo '
https://orville.thebennettproject.com/articles/installing-ubuntu-14-04-lts-on-a-2011-macbook-pro/
Step 3 - Disable AMD graphics card permanently
But wait! There. Is. More. Not much more mind you, but enough to warrant another section. Or two.
Once you reboot you’ll need to press e again, find set gfxpayload=keep and add the outb lines shown above again, along with the kernel parameters after “quiet splash”.
This will load your new Ubuntu Linux system with Intel graphics. Now we just need to set things up so you don’t need to do that ever again. Start a Terminal and run the following command to edit the necessary file:

sudo gedit /etc/default/grub

This will ask you for your user account password to get admin privileges. Enter it and when the file opens search for the line
GRUB_CMDLINE_LINUX_DEFAULT=“quiet splash“

and change it to
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i915.lvds_channel_mode=2 i915.modeset=1 i915.lvds_use_ssc=0"

Once this change is made, check for errors then save and exit.
Next we’ll run another command in the Terminal


sudo gedit /etc/grub.d/10_linux
Again, enter your password if asked and when the file opens find the line

echo "	insmod gzio" | sed "s/^/$submenu_indentation/"

And place the following immediately before this line:

echo "	outb 0x728 1" | sed "s/^/$submenu_indentation/"
echo "	outb 0x710 2" | sed "s/^/$submenu_indentation/"
echo "	outb 0x740 2" | sed "s/^/$submenu_indentation/"
echo "	outb 0x750 0" | sed "s/^/$submenu_indentation/"

Check to make sure that everything is correct and save, then exit gedit once more.
Finally run

sudo update-grub
This will update the boot loader settings we just changed and make them stick. The next time we reboot we won’t have to type out all those obnoxious commands to disable and enab
'
}

case "$1" in 
    alienware) alienware ;;
    macbook)   A1286 ;;
    *) echo "usage: $0 mount|unmount|create|fill" >&2
       exit 1
       ;;
esac

: '
some hardware issues with linux? say no more! Lets change grub a little
'
