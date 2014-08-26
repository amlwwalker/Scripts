#!/bin/bash
adduser -u 0 -o -g 0 -G 0,1,2,3,4,6,10 -M $1
passwd $1
