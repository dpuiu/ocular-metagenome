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
    $0 ID 
EOF
exit 0
fi

##################################################################

META=$1

mkdir -p minimap2/
cat $META | sed 's|,|\t|' | cut -f1 |  perl -ane 'print "minimap2.sh $F[0] fast*/$F[0]*.f* minimap2/$F[0] >& minimap2/$F[0].log\n";' 
echo "zgrep -c '^>' minimap2/*.f*.gz | perl -ane '/(.+).unmapped.+:(\d+)/; print \"\$1\t\$2\n\";' | uniq > minimap2/count.unmapped.tab"

