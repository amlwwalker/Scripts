#!/bin/bash

# getopt.sh example

# Execute getopt
ARGS=$(getopt -o a:b:c -l "ay:,bee:,cee" -n "getopt.sh" -- "$@");

#Bad arguments
if [ $? -ne 0 ];
then
  exit 1
fi

eval set -- "$ARGS";

while true; do
  case "$1" in
    -a|--ay)
      shift;
      if [ -n "$1" ]; then
        echo "-a used: $1";
        shift;
      fi
      ;;
    -b|--bee)
      shift;
      if [ -n "$1" ]; then
        echo "-b used: $1";
        shift;
      fi
      ;;
    -c|--cee)
      shift;
      echo "-c used";
      ;;
    --)
      shift;
      break;
      ;;
  esac
done
