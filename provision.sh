#!/usr/bin/env bash

#set -x

rm -rf /root/boot/temp/provisions*
rm -rf /root/boot/temp/gist*

_provision_url=`cat /root/boot/config/provisioning`

wget -q -O /root/boot/temp/provisions.tar.gz $_provision_url

_tar_output=`cd /root/boot/temp/; tar -zxvf provisions.tar.gz`

_tar_output=( $_tar_output )

for _toutput in ${_tar_output[@]}; do

	_script_name=`echo $_toutput | awk -F "/" '/.sh/ {print $2}'`
	_script_fullname=`echo /root/boot/temp/$_toutput | awk '/.sh/ {print $1}'`

	_chmod_output=`chmod +x $_script_fullname 2>&1`

	if [[ "$_script_fullname" != "" ]]; then

		if [[ "$1" != "provision" ]]; then

			if [[ "$_script_fullname" == *Reboot* ]]; then
				eval $_script_fullname
			fi
		else
			eval $_script_fullname
		fi
	fi
done
