#!/bin/bash
export AWS_ACCESS_KEY='AKIAJP5YBUABRN4XK7MA'
export AWS_SECRET_KEY='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'

export JAVA_HOME=/usr
export EC2_HOME=/opt/aws
export PATH=$PATH:$EC2_HOME/bin

/root/boot/bin/ec2-metadata | grep public-ipv4 | awk '{print $2}'
