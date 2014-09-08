#!/bin/bash

if [ -f /root/boot/booted ]; then
	mount -a >> /root/boot/logs/mount.log 2>&1
	sleep 10
        /root/boot/provision.sh >> /root/boot/logs/provisioning.log 2>&1
	/etc/init.d/mysql restart >> /root/boot/logs/services.log 2>&1
	/etc/init.d/httpd restart >> /root/boot/logs/services.log 2>&1
fi

if [ ! -f /root/boot/booted ]; then
	sleep 10
	/root/boot/bin/mkswap.sh >> /root/boot/logs/install.log 2>&1
	/root/boot/bin/mnt_all.sh >> /root/boot/logs/install.log 2>&1
	/root/boot/bin/attach_eip.sh >> /root/boot/logs/install.log 2>&1
	/root/boot/provision.sh provision >> /root/boot/logs/provisioning.log 2>&1
	touch /root/boot/booted
	sleep 10
	/sbin/shutdown -r now
fi

