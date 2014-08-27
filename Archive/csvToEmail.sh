#!/bin/bash

while read line; do
firstName=$(echo $line | awk -F',' '{ print $1 }');
secondName=$(echo $line | awk -F',' '{ print $2 }');
jobRole=$(echo $line | awk -F',' '{ print $4 }');
	replace="\""
	with=""
	firstName=${firstName//$replace/$with}
	secondName=${secondName//$replace/$with}
	jobRole=${jobRole//$replace/$with}
echo $firstName","$secondName","$firstName"."$secondName"@baesystemsdetica.com,"$jobRole;
done < $1
