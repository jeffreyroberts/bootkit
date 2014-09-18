#!/bin/bash
cd /opt/aws/bin/

export AWS_ACCESS_KEY='AKIAJP5YBUABRN4XK7MA'
export AWS_SECRET_KEY='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'
export EC2_HOME=/opt/aws
export JAVA_HOME=/usr

vip=`cat /root/boot/config/vip`
bip=`cat /root/boot/config/bip`

myip=`/root/boot/bin/myip.sh`

myname=`uname -n`

if [ "$myname" == "jlr-lb-01.aws" ]; then
	tag='jlr-lb-02.aws'
else
	tag='jlr-lb-01.aws'
fi

if [ "$myip" == "$vip" ]; then

	instance=`/opt/aws/bin/ec2-describe-instances --region us-west-2 -F "tag-value=$tag" --filter "instance-state-code=16" | grep INSTANCE | awk '{print $2}'`
	myinstance=`/root/boot/bin/ec2-metadata -i | awk '{ print $2 }'`

	echo "VRRP "`date "+%m%d%Y%H%M"` >> /tmp/failover.log

	if [ "$instance" != "" ]; then

		# Mapping VIP to primary server
		./ec2-associate-address --aws-access-key $AWS_ACCESS_KEY --aws-secret-key $AWS_SECRET_KEY $vip -i $instance --region us-west-2 2>&1 >> /tmp/failover.log

		# Mapping BIP to secondary server
		./ec2-associate-address --aws-access-key $AWS_ACCESS_KEY --aws-secret-key $AWS_SECRET_KEY $bip -i $myinstance --region us-west-2 2>&1 >> /tmp/failover.log

		# Rebooting secondary server
		./ec2-reboot-instances $myinstance --region us-west-2 >> /tmp/failover.log
	fi
fi
