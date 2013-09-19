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
echo " running: A full TCP SYN Scan containing OS and service Version info "
echo " $EXEC -sS -Pn -A -iL $TARGET -p- -oA nmap.$REPORT.full.tcp.results"
echo 
echo " continue y/n? "

read ANSWER

echo

if [ $ANSWER = "y" ]; then 
	if [ -d $DIR ]; then
		$EXEC -sS -Pn -A -iL -v $TARGET -p- -oA $DIR/nmap.$REPORT.full.tcp.results		
	else
		mkdir $DIR
		$EXEC -sS -Pn-A -iL -v $TARGET -p- -oA $DIR/nmap.$REPORT.full.tcp.results		
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
