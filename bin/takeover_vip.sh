#!/bin/bash
cd /opt/aws/bin/

export AWS_ACCESS_KEY=''
export AWS_SECRET_KEY=''
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

if [ "$myip" != "$vip" ]; then

	instance=`/root/boot/bin/ec2-metadata -i | awk '{ print $2 }'`
	instance2=`/opt/aws/bin/ec2-describe-instances --region us-west-2 -F "tag-value=$tag" --filter "instance-state-code=16" | grep INSTANCE | awk '{print $2}'`

	echo "VRRP MASTER "`date "+%m%d%Y%H%M"` >> /tmp/failover.log

	# Mapping VIP to working server
	./ec2-associate-address --aws-access-key $AWS_ACCESS_KEY --aws-secret-key $AWS_SECRET_KEY $vip -i $instance --region us-west-2 2>&1 >> /tmp/failover.log

	# Reboot broken server
#	./ec2-reboot-instances $instance2 --region us-west-2 >> /tmp/failover.log

	# Associate secondary ip to broken instance
	./ec2-associate-address --aws-access-key $AWS_ACCESS_KEY --aws-secret-key $AWS_SECRET_KEY $bip -i $instance2 --region us-west-2 2>&1 >> /tmp/failover.log
fi
