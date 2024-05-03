#!/bin/bash -eux

##################################################################

if [ "$1" -eq "-h" ]  ; then
cat << EOF
   SCRIPT WHICH RUNS `basename $0 .sh`

   ARGUMENTS:
    ID           : sample name/id

  SETUP ENVIRONMENT (once)
    . ./init.sh

  USAGE:
    $0 ID 
EOF
exit 0
fi

##################################################################

ID=$1
fastqerq-dump --fasta $ID
