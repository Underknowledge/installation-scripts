#!/bin/bash
sudo tar -cvf ha28_configuration_backup.tar \
/home/user/.ssh/ \
/var/spool/cron/ \
/etc/mosquitto/ \
/var/spool/cron/crontabs/ \
/usr/bin/userscripts/ \
/etc/mosquitto/ \
/etc/ssh/ \
/etc/fstab \
/home/chron/.smbcredentials \
/etc/default/grub \
/etc/grub.d/10_linux \
/home/user/.bashrc \
/home/user/.bash_history \
/home/homeassistant/.bash_history \
/home/homeassistant/.bashrc \
/opt/docker-compose.yml \
/usr/share/samba/smb.conf \
/etc/nginx/ \
--exclude=/etc/nginx/modules-available \
--exclude=/etc/nginx/modules-enabled \
--exclude=/etc/nginx/snippets
