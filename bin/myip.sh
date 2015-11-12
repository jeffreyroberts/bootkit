#!/bin/bash
export AWS_ACCESS_KEY=''
export AWS_SECRET_KEY=''

export JAVA_HOME=/usr
export EC2_HOME=/opt/aws
export PATH=$PATH:$EC2_HOME/bin

/root/boot/bin/ec2-metadata | grep public-ipv4 | awk '{print $2}'
