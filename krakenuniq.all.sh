#!/bin/bash -eu

##################################################################

if [ "$1" == "-h" ] || [ "$1" == "--help" ]  ; then
cat << EOF
   SCRIPT WHICH RUNS `basename $0 .sh`

   ARGUMENTS:
    META           : metadata file

  SETUP ENVIRONMENT (once)
    . ./init.sh

  USAGE:
    $0 ID.txt
EOF
exit 0
fi

##################################################################
test -s $1
cat  $1 | sed 's|,|\t|' | cut -f1 | tail -n +2 | perl -ane 'print "krakenuniq.sh $F[0] $ENV{ALIGNER}/$F[0].unmapped"."_?.fasta.gz $ENV{ALIGNER}/$F[0].unmapped\n";' 
