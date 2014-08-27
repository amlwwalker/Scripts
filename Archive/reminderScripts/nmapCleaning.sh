#!/bin/bash

#Sed used to remove lines that contain string
sed -i '/string to match/d' $fileToRemoveFrom

#Nice bit of code to find lines containing in a file, strip them to a new file, but only save the 5th field
cat def.results | grep -i "foobar" | awk -F' ' '{ print $5 }' > file.txt

#Rename part of a file name in more than one file - replaces foo with bar
for i in ./*foo*;do mv -- "$i" "${i//foo/bar}";done

#Grep for '/open/' and grab the second field out of a gnmap file
grep '/open/' customPorts.gnmap | awk -F' ' '{ print $2 }'

#clean ip's sort into order and make unique
sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n allips.lst | uniq

