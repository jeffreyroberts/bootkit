#!/bin/bash

set -x 

/root/boot/bin/reset.sh

export AWS_ACCESS_KEY='AKIAJP5YBUABRN4XK7MA'
export AWS_SECRET_KEY='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'

export JAVA_HOME=/usr
export EC2_HOME=/opt/aws
export PATH=$PATH:$EC2_HOME/bin

region=`cat /root/boot/config/region`

instance=`/root/boot/bin/ec2-metadata -i | awk '{ print $2 }'`
if [ "$1" != "" ]; then
	d=`date '+%m%d%Y %H%M'`
	d="$d $1"
else
	d=`date '+%m%d%Y %H%M'`
	d=$(echo $d `uname -n`)
fi

described=`ec2-describe-instances $instance --region $region`

nomap=`ec2-describe-instances $instance --region $region | grep 'BLOCKDEVICE' | awk '{print $2}' | grep -v 'sda' | grep -v 'sdb'`
nomap=( $nomap )

map=`ec2-describe-instances $instance --region $region | grep 'BLOCKDEVICE' | awk '{print $2}' | grep -v 'sdc' | grep -v 'xvd'`
map=( $map )

mapable=''

for mapping in ${map[@]}; do
	mapable="$mapable -b \"$mapping=::true\""
done

for nomapping in ${nomap[@]}; do
	mapable="$mapable -b \"$nomapping=none\""
done

ami=`ec2-create-image $instance --name "$d" --description "$d AUTOAMI" --no-reboot $mapable --region $region`
ami=$(echo $ami | awk '{print $2}')
# ami='ami-4dde9f7d'

spotid=`ec2-describe-instances $instance --region $region | grep spot | awk '{print $20}'`

spotreq=`ec2-describe-spot-instance-requests $spotid --region $region`
price=$(echo $spotreq | grep 'SPOTINSTANCEREQUEST' | awk '{print $3}')
instancetype=$(echo $spotreq | grep 'SPOTINSTANCEREQUEST' | awk '{print $10}')
az=$(echo $spotreq | grep 'SPOTINSTANCEREQUEST' | awk '{print $13}')
key=$(echo $spotreq | grep 'SPOTINSTANCEREQUEST' | awk '{print $11}')

spot=`ec2-request-spot-instances $ami --price $price --instance-count 1 --type persistent --key $key --instance-type $instancetype --availability-zone $az --region $region` 

echo $spot

cancel=`ec2-cancel-spot-instance-requests $spotid --region $region`

echo $cancel

terminate=`ec2-terminate-instances $instance --region $region`

echo $terminate

echo
echo
echo "Relaunching Instance"
echo
echo
