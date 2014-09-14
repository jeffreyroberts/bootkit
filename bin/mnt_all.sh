#!/bin/bash

set -x

. ~/.bashrc

export AWS_ACCESS_KEY='AKIAJP5YBUABRN4XK7MA'
export AWS_SECRET_KEY='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'

export JAVA_HOME=/usr
export EC2_HOME=/opt/aws
export PATH=$PATH:$EC2_HOME/bin

instance=`/root/boot/bin/ec2-metadata -i | awk '{ print $2 }'`

devices=('g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z')
volumes=$(cat /root/boot/config/vols)
volumes=$(echo $volumes)
volumes=( $volumes )

region=`cat /root/boot/config/region`

count=0
for vol in ${volumes[@]}; do
	/opt/aws/bin/ec2-attach-volume $vol -i $instance -d /dev/xvd${devices[$count]} -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY --region $region >> /tmp/0.log
	count=$(($count + 1))
done

fdisk -l

if [ "$1" == "format" ]; then
		
	sleep 30

	count=0
	for vol in ${volumes[@]}; do
		mkfs -t ext4 /dev/xvd${devices[$count]}
		count=$(($count + 1))
	done
fi
