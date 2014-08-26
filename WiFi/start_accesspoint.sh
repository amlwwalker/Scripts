#!/bin/bash

######################################################################################
######################################################################################

# Authors: Decoded, Alex Walker, Luuk Derksen

######################################################################################

# SETUP


######################################################################################
######################################################################################

# To setup an accesspoint we can use airbase-ng
airbase-ng -a 06:18:0A:D9:F6:A0 --essid "DO NOT CONNECT" -c 1 -P mon0


# Make the accesspoint externally facing
ifconfig at0 up 192.168.99.1 netmask 255.255.255.0


# Start the DHCP server.
route add -net 192.168.99.0 netmask 255.255.255.0 gw 192.168.99.1
service isc-dhcp-server start



iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain

iptables --table nat --append POSTROUTING --out-interface wlan3 -j MASQUERADE
iptables --append FORWARD --in-interface at0 -j ACCEPT
iptables --table nat --append PREROUTING --protocol udp --dport 53 -j DNAT --to 10.128.128.128


# We can do this > for driftnet.
$ iptables -t nat -D PREROUTING --protocol tcp --dport 80 -j REDIRECT --to-ports 8080
$ iptables -t nat -D PREROUTING --protocol tcp --dport 443 -j REDIRECT --to-ports 8080


echo 1 > /proc/sys/net/ipv4/ip_forward
