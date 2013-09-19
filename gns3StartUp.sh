#!/bin/bash
#Script to setup GNS3
#-gives GNS3 sudo rights
#-sets up a loopback interface called tap0

#Setting up dialog box to input ip
DIALOG=${DIALOG=dialog}
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
ipaddress="172.16.1";

#Testing whether uml-utilities are installed:
if !(type tunctl > /dev/null 2>&1); then #i.e check it is NOT installed
	echo "You need to install uml-utilities from ubuntu repo. Aborting";
	echo "Remember you will also need to run this script as root";
	exit 1;
fi;

if !(type arp-scan > /dev/null 2>&1); then #i.e check it is NOT installed
	echo "You need to install arps-can from ubuntu repo. Aborting";
	exit 1;
fi;
echo "WARNING: You need dialog installed: apt-get install dialog"
echo "Packages seem to be installed correctly, beginning setup of local ethernet adaptor...Press any key";
read line
modprobe tun
tunctl
correctEntry=1

while [ $correctEntry == "1" ] 
do
	$DIALOG --title "Enter ip" --clear \
	--inputbox "Please enter the LAST byte for a unique ip. Should be in the $ipaddress.x region" 16 51 2> $tempfile
	retval=$?
	case $retval in
	0)
#check whether the entered value is an integer	
	if [ "`cat $tempfile`" -eq "`cat $tempfile`" 2> /dev/null ] ; then
		correctEntry=0
		echo "$ipaddress.`cat $tempfile`";
	fi;;
	1)
	echo "Cancel pressed, Aborting";
	exit 1;;
	255)
	echo "Escape pressed. Aborting";
	exit 1;;
	esac

done
echo "running ifconfig to setup tap0 on ip address: $ipaddress.`cat $tempfile` and netmask: netmask 255.255.255.0 up";
ifconfig tap0 $ipaddress.`cat $tempfile` netmask 255.255.255.0 up

ifconfig

echo "Above displays tap0 credentials. Remember to run an arp-scan once gns3 setup. Press any key to start gns3";
read line;
/usr/share/gns3/gns3 &

echo "DISABLED!:Setting default gateway for tap0 to 172.16.1.1. Disconnect from other networks now."
#route add default gw 172.16.1.1 tap0
echo "Press any key to continue"
read line;
echo "Start all virtual devices in GNS3 - click large green triangle. Press any key to begin running an arp scan"
read line;
arp-scan --interface=tap0 --localnet;

exit 1;







