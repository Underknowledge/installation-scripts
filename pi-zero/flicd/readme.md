# flic daemon
this is just an simple Install script wich install [[flic](https://github.com/50ButtonsEach/fliclib-linux-hci)] as a daemon.
I intended it for an Raspberry Pi Zero - but it should run on any armv6l hardware. Easy to change [1](https://github.com/Underknowledge/installation-scripts/blob/master/pi-zero/flicd/flicd-installation-script.sh#L20) [2](https://github.com/50ButtonsEach/fliclib-linux-hci/tree/master/bin) 
Sadly flic needs exclusive use of the Bluetooth radio to function, So no other fancy Bluetooth services like [Monitor](https://github.com/andrewjfreyer/monitor) ;) 


Download and run this simple script with:
``` 
  $ curl https://raw.githubusercontent.com/Underknowledge/installation-scripts/master/pi-zero/flicd/flicd-installation-script.sh > ~/flicd-installation-script.sh
  $ sudo chmod +x ~/flicd-installation-script.sh
  $ cd ~
  $ ./flicd-installation-script.sh
``` 


