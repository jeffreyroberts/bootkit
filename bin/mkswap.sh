#!/bin/bash

echo -e "n\np\n1\n\n\nw" | /sbin/fdisk /dev/xvdf
echo "/dev/xvdf1   swap swap defaults 0 0" >> /etc/fstab
/sbin/mkswap /dev/xvdf1
/sbin/swapon /dev/xvdf1
