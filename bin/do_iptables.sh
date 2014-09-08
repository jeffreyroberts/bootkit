#!/bin/bash
set -x
iptables -N ssh
iptables -N blacklist

iptables -A blacklist -m recent --name blacklist --set
iptables -A blacklist -j DROP

iptables -A ssh -m recent --update --name blacklist --seconds 600 --hitcount 1 -j DROP
iptables -A ssh -m recent --set --name counting1
iptables -A ssh -m recent --set --name counting2
iptables -A ssh -m recent --set --name counting3
iptables -A ssh -m recent --set --name counting4

iptables -A ssh -m recent --update --name counting2 --seconds 120 --hitcount 100 -j blacklist

iptables -A ssh -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

iptables -A INPUT -p TCP -m state --state NEW -j ssh

iptables -A INPUT -j DROP


