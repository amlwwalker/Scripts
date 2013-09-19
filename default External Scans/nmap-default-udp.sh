#!/bin/bash

TARGET=$1
REPORT=$2 
EXEC=/usr/bin/nmap
DIR=results

if [ -z "$TARGET" ]
then
	echo "no target defined!!"
	echo "$0 target.txt acme.vlan1"
	exit
fi

if [ -z "$REPORT" ]
then
	echo "no report defined!!"
	echo "$0 target.txt acme.vlan1"
	exit
fi 

echo " ** WARNING ABOUT TO START PORT SCAN ** "
echo
echo " running: A default UDP Scan containing OS and service Version info "
echo " $EXEC -sU -Pn -A --version-intensity 0 -iL $TARGET -oA nmap.$REPORT.default.udp.results"
echo 
echo " continue y/n? "

read ANSWER

echo

if [ $ANSWER = "y" ]; then 
	if [ -d $DIR ]; then
		$EXEC -sU -Pn -A --version-intensity 0 -iL $TARGET -v -oA $DIR/nmap.$REPORT.default.udp.results		
	else
		mkdir $DIR
		$EXEC -sU -Pn -A --version-intensity 0 -iL $TARGET -v -oA $DIR/nmap.$REPORT.default.udp.results		
	fi
	
	echo
	echo " ** FINISHED ** "
	echo
	exit
fi

if [ $ANSWER = "n" ]
then
	echo
	echo " ** WIMP ** "
	echo
fi
