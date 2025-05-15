#!/bin/sh
echo "Stripping line numbers from Basic program." >&2
if [ -z "$1" ] ; then
   echo "No parameter reading from stdin" >&2
else
   echo "Reading from file <$1>" >&2
fi
cut -f2- -d" " $1



