#!/bin/bash

while read line;
do
	echo $line
done < $1

for x in $(cat $filename);
do
	echo $x;
done > savetofile.txt
