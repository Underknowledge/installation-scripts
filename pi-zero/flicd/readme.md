# flic daemon
this is just an simple Install script wich install [[flic](https://github.com/50ButtonsEach/fliclib-linux-hci)] as a daemon.<br>
[Flic Binarys](https://github.com/50ButtonsEach/fliclib-linux-hci/tree/master/bin) ]
I intended it for an Raspberry Pi Zero *first* - but it should run on any armv6l, i386 or	x86_64hardware. <br>
Sadly flic needs exclusive use of the Bluetooth radio to function, So no other fancy Bluetooth services like [Monitor](https://github.com/andrewjfreyer/monitor) <br>
;) 

 <br>
Download and run this script with:

``` 
  $ curl https://raw.githubusercontent.com/Underknowledge/installation-scripts/master/pi-zero/flicd/flicd-installation-script.sh > ~/flicd-installation-script.sh
  $ sudo chmod +x ~/flicd-installation-script.sh
  $ cd ~
  $ ./flicd-installation-script.sh
``` 
 <br>
 <br>
to pair a button just press it for +7 secconds <br>
when you facing issues pairing run 'resetflicdaemon' it will delete the database and reboot the pi <br>
