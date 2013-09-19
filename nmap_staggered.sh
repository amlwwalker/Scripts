#!/bin/bash

TARGET=$1 #the file with the ip's in
EXEC=nmap
DIR=results
type="default"
if [ -z "$TARGET" ]
then
	echo "no target defined!!"
	exit
fi

echo " ** WARNING ABOUT TO START PORT SCAN ** "
echo
echo " running: A $type TCP SYN Scan containing OS and service Version info "
while read p; do
	report=$(echo $p | cut -d'/' -f1)
	if [ -d $DIR ]; then
		echo "saving to directory:" $DIR;
	else
		mkdir $DIR
	fi
command="-sS -vv -Pn -n -p-";
 echo $command; 	
echo " $EXEC $command $p -oA $DIR/nmap.$report.$type.tcp.results"
		$EXEC $command $p -oA $DIR/nmap.$report.$type.tcp.results
done < $TARGET


