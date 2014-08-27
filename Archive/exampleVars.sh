#!/bin/bash
 
# Execute getopt on the arguments passed to this program, identified by the special character $@
PARSED_OPTIONS=$(getopt -n "$0"  -o h123: --long "help,one,two,three:"  -- "$@")
 
#Bad arguments, something has gone wrong with the getopt command.
if [ $? -ne 0 ];
then
  exit 1
fi
 
# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"
 
 
# Now goes through all the options with a case and using shift to analyse 1 argument at a time.
#$1 identifies the first argument, and when we use shift we discard the first argument, so $2 becomes $1 and goes again through the case.
while true;
do
  case "$1" in
 
    -h|--help)
      echo "usage $0 -h -1 -2 -3 or $0 --help --one --two --three"
     shift;;
 
    -1|--one)
      echo "One"
      shift;;
 
    -2|--two)
      echo "Dos"
      shift;;
 
    -3|--three)
      echo "Tre"
 
      # We need to take the option of the argument "three"
      if [ -n "$2" ];
      then
        echo "Argument: $2"
      fi
      shift 2;;
 
    --)
      shift
      break;;
  esac
done
