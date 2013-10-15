#!/bin/bash

instring="version 1.5.8"
outstring=${instring//1.5.8/1.5.9}

echo $outstring
