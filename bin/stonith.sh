#!/bin/bash

set -x

myname=`uname -n`
status=`pcs status`
myip=`/root/boot/bin/myip.sh`
vip=`cat /root/boot/config/vip`
banner="livefrontendIP0	(ocf::heartbeat:AWSVip):	Started jlr-lb-01.aws"
banner2="haproxyLB	(ocf::heartbeat:haproxy):	Started jlr-lb-01.aws"

if [ "$myip" == "$vip" ] && [ "$myname" == "jlr-lb-02.aws" ]; then
	if [[ "$status" == *$banner* ]] && [[ "$status" == *$banner2* ]]; then
		/root/boot/bin/handover_vip.sh
	fi
fi
