#!/bin/bash

touch /var/lock/subsys/killcs

if [ "$1" != "didgit" ]; then
	cd /root/boot/
	/usr/bin/git pull origin master
	/root/boot/boot.sh didgit
	exit 0
fi

export AWS_ACCESS_KEY=''
export AWS_SECRET_KEY=''

export JAVA_HOME=/usr
export EC2_HOME=/opt/aws
export PATH=$PATH:$EC2_HOME/bin

if [ -f /root/boot/booted ]; then

	mount -a >> /root/boot/logs/mount.log 2>&1

	sleep 10

        /root/boot/provision.sh >> /root/boot/logs/provisioning.log 2>&1

	/etc/init.d/mysql restart >> /root/boot/logs/services.log 2>&1
	/etc/init.d/httpd restart >> /root/boot/logs/services.log 2>&1

fi

if [ ! -f /root/boot/booted ]; then

	(crontab -l ; echo "*/5 * * * * /root/boot/bin/fresh_configs.sh") | sort - | uniq - | crontab -

	sleep 10

#	/root/boot/bin/mkswap.sh >> /root/boot/logs/install.log 2>&1
	/root/boot/bin/mnt_all.sh >> /root/boot/logs/install.log 2>&1
	/root/boot/bin/attach_eip.sh >> /root/boot/logs/install.log 2>&1
	/root/boot/provision.sh provision >> /root/boot/logs/provisioning.log 2>&1
	/root/boot/bin/ha boot >> /root/boot/logs/ha.log 2>&1

	touch /root/boot/booted

	sleep 10

	/sbin/shutdown -r now

fi

