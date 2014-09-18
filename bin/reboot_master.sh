#!/bin/bash
cd /opt/aws/bin/

export AWS_ACCESS_KEY='AKIAJP5YBUABRN4XK7MA'
export AWS_SECRET_KEY='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'
export EC2_HOME=/opt/aws
export JAVA_HOME=/usr

tag='jlr-lb-01.aws'

instance2=`/opt/aws/bin/ec2-describe-instances --region us-west-2 -F "tag-value=$tag" --filter "instance-state-code=16" | grep INSTANCE | awk '{print $2}'`

echo "REBOOT MASTER "`date "+%m%d%Y%H%M"` >> /tmp/failover.log

# Reboot broken server
./ec2-reboot-instances $instance2 --region us-west-2 >> /tmp/failover.log
