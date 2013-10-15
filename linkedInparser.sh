#!/bin/bash

position="left"
while read line; do
	tempLine=$(echo $line | awk -F'<string>' '{ print $2 }');
	address=$(echo $tempLine | awk -F'??' '{ print $1 }');
	job=$(echo $tempLine | awk -F'??' '{ print $3 }');
	name=$(echo $tempLine | awk -F'??' '{ print $5}');
	email=$(echo $tempLine | awk -F'??' '{ print $7 }');
	description=$(echo $tempLine | awk -F'??' '{ print $9 }');
	replace="</string>"
	with=""
	description=${description//$replace/$with}
	randomId=$(echo $[ 100000000 + $[ RANDOM % 999999999 ]]);
	randomModified=$(echo $[ 1000000000000 + $[ RANDOM % 9999999999999 ]]);
	echo "<node CREATED=\"1380529239661\" ID=\"ID_$randomId\" MODIFIED=\"$randomModified\" POSITION=\"$position\" TEXT=\"$name\">"
	randomId=$(echo $[ 100000000 + $[ RANDOM % 999999999 ]]);
	randomModified=$(echo $[ 1000000000000 + $[ RANDOM % 9999999999999 ]]);
	echo "<node CREATED=\"1380529239661\" ID=\"ID_$randomId\" MODIFIED=\"$randomModified\" POSITION=\"$position\" TEXT=\"$address\" />"
        randomId=$(echo $[ 100000000 + $[ RANDOM % 999999999 ]]);
	randomModified=$(echo $[ 1000000000000 + $[ RANDOM % 9999999999999 ]]);
	echo "<node CREATED=\"1380529239661\" ID=\"ID_$randomId\" MODIFIED=\"$randomModified\" POSITION=\"$position\" TEXT=\"$job\" />"
	randomId=$(echo $[ 100000000 + $[ RANDOM % 999999999 ]]);
	randomModified=$(echo $[ 1000000000000 + $[ RANDOM % 9999999999999 ]]);
	echo "<node CREATED=\"1380529239661\" ID=\"ID_$randomId\" MODIFIED=\"$randomModified\" POSITION=\"$position\" TEXT=\"$email\" />"
	randomId=$(echo $[ 100000000 + $[ RANDOM % 999999999 ]]);
	randomModified=$(echo $[ 1000000000000 + $[ RANDOM % 9999999999999 ]]);
	echo "<node CREATED=\"1380529239661\" ID=\"ID_$randomId\" MODIFIED=\"$randomModified\" POSITION=\"$position\" TEXT=\"$description\" />"
	echo "</node>"
	if [[ $position == "left" ]]
	then
		position="right";
	else position="left";
	fi	
done < $1

