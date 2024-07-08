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

mkdir -p minimap2_unmapped/
cat $META | sed 's|,|\t|' | cut -f1 |  perl -ane 'print "minimap2.sh $F[0] minimap2/$F[0]*.f* minimap2_unmapped/$F[0] >& minimap2_unmapped/$F[0].log\n";' 
echo "zgrep -c '^>' minimap2_unmapped/*.f*.gz | perl -ane '/(.+).unmapped.+:(\d+)/; print \"\$1\t\$2\n\";' | uniq > minimap2_unmapped/count.unmapped.tab"

