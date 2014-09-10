#!/bin/bash

export AWS_ACCESS_KEY='AKIAJP5YBUABRN4XK7MA'
export AWS_SECRET_KEY='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'

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
	sleep 10

	tag=`cat /root/boot/config/tags`
	
	if [[ "$tag" != "" ]]; then
		instance=`/root/boot/bin/ec2-metadata -i | awk '{ print $2 }'`
		ec2-create-tags $instance --tag "tag=$tag" --region us-west-2
	fi

#	/root/boot/bin/mkswap.sh >> /root/boot/logs/install.log 2>&1
	/root/boot/bin/mnt_all.sh >> /root/boot/logs/install.log 2>&1
	/root/boot/bin/attach_eip.sh >> /root/boot/logs/install.log 2>&1
	/root/boot/provision.sh provision >> /root/boot/logs/provisioning.log 2>&1
	/root/boot/bin/ha >> /root/boot/logs/ha.log 2>&1
	touch /root/boot/booted
	sleep 10
	/sbin/shutdown -r now
fi

