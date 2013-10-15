#!/bin/bash

while read line; do
firstName=$(echo $line | awk -F',' '{ print $1 }');
secondName=$(echo $line | awk -F',' '{ print $2 }');
	replace="\""
	with=""
	firstName=${firstName//$replace/$with}
	secondName=${secondName//$replace/$with}
echo $firstName"."$secondName"@baesystemsdetica.com";
done < $1
