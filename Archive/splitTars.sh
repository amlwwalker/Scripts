#!/bin/bash

##################
#Author:Alex Walker 
#Ver: 01
#Dependencies: SSHpass

#Script to split a tar into multiple chunks for scp-ing to help deal upload interrupt issues.

#Instructions:
#filename is the tar to split
#location is the ssh location you want to send it to tim@192.168.0.1:/home/tim
#splitsize is the size of each tar segement to push
#example useage
#./split-tars.sh filename.tar tim@192.168.0.1:/home/tim 1M

#tar up a file then split it for sshing
#To put the files back together use cat part* parts.tar the other end
##################

filename=$1
location=$2
splitsize=$3


mkdir temp
split -b $splitsize $filename temp/part

echo -n Server Password:
read -s password


isInstalled() {
if (type -p "$1" > /dev/null) ; then
   return 0
else     
   return 1
fi      
}

if !(isInstalled "sshpass" ) then
	echo "$i not installed, downloading from repo"
	apt-get install $i
fi              

for f in temp/part*
do
sshpass -p $password scp -v $f $location;
done

rm -rf temp
