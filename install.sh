#!/bin/bash

old_hostname="$( hostname )"

echo "Enter the hostname for this instance $ "
read -e hostname

echo "Enter the Elastic IP Address or empty for none $ "
read -e eip

echo "Enter the Backup IP Address or empty for none $ "
read -e bip

echo "Enter the Floating IP Address or empty for none $ "
read -e vip

echo "Enter the provisioning Gist download URL $ "
read -e gist

echo "Updating hostname..."
hostname $hostname
sed -i "s/HOSTNAME=.*/HOSTNAME=$hostname/g" /etc/sysconfig/network
if [ -n "$( grep "$old_hostname" /etc/hosts )" ]; then
 sed -i "s/$old_hostname/$hostname/g" /etc/hosts
else
 echo -e "$( hostname -I | awk '{ print $1 }' )\t$hostname" >> /etc/hosts
fi

echo "Setting EIP in config..."
echo $eip > /root/boot/config/eip

echo "Setting Backup IP in config..."
echo $bip > /root/boot/config/bip

echo "Setting Floating IP in config..."
echo $vip > /root/boot/config/vip

echo "Getting current old IP..."
my_old_local_ip=`cat /root/boot/config/myoldip`

echo "Setting old ip in config..."
my_local_ip=$(/sbin/ifconfig | grep -A 1 'eth0' | grep 'inet addr:10' | awk -F ":" '{print $2}' | awk '{print $1}')
echo $my_local_ip > /root/boot/config/myoldip

if [ "$my_old_local_ip" != "" ]; then
	echo "Updating hosts file..."
	sed -i "s/$my_old_local_ip/$my_local_ip/g" /etc/hosts
fi

echo "Setting the Gist download URL..."
echo $gist > /root/boot/config/provisioning

echo "Getting instance ID..."
instance=`/root/boot/bin/ec2-metadata -i | awk '{ print $2 }'`

echo "Found instance ID: $instance"

echo "Getting instance region..."
region_temp=`/root/boot/bin/ec2-metadata | grep placement | awk '{print $2}'`
region=$(echo $region_temp | head -c +`expr ${#region_temp} - 1`)

echo "Found region: $region"

echo "Tagging instance..."
echo $hostname > /root/boot/config/tags
ec2-create-tags $instance --region $region -tag "node=$hostname"

echo "Getting instace vols"
vols=`ec2-describe-volumes --region us-west-2 --filter="tag-value=$hostname" | grep 'VOLUME' | awk '{print $2}'`

echo $vols > /root/boot/config/vols
vols=($vols)
echo "Found Volumes: ${#vols[@]}"

echo "Setting reboot crontab..."
(crontab -l ; echo "@reboot /root/boot/boot.sh") | sort - | uniq - | crontab -

echo "Attaching Volumes..."
echo "Format Drives? [y/N] $ "
read -e format
if [ "$1" == "y" ] || [ "$1" == "Y" ]; then
	/root/boot/bin/mnt_all.sh format
else
	/root/boot/bin/mnt_all.sh
fi

echo "Format and mount SWAP..."
/root/boot/bin/mkswap.sh

echo "#######################################################"
echo "#                                                     #"
echo "# Don't forget to set your mount points in /etc/fstab #"
echo "#                                                     #"
echo "#######################################################"
echo "Press any key to reboot..."
read -e bling

echo "Rebooting machine..."
shutdown -r now
