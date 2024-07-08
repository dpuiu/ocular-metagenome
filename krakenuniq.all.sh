#!/bin/bash -eux

##################################################################

if [ "$1" == "-h" ] || [ "$1" == "--help" ]  ; then
cat << EOF
   SCRIPT WHICH RUNS `basename $0 .sh`

   ARGUMENTS:
    PRJ           : BioProject id

  SETUP ENVIRONMENT (once)
    . ./init.sh

  USAGE:
    $0 ID 
EOF
exit 0
fi

##################################################################

export PRJ=$1

test -s ../../metadata/$PRJ.txt
cat  ../../metadata/$PRJ.txt | sed 's|,|\t|' | cut -f1 | tail -n +2 | perl -ane 'print "krakenuniq.sh $F[0] ../../$ENV{PRJ}/minimap2/$F[0].unmapped"."_?.fasta $F[0]\n";' 
echo "grep 'Homo sapiens' *species.bracken |  perl -ane '/(.+?).species.+\t(\d+)\t(\d\.\d+)$/; print \"\$1\t\$2\t\$3\n\";'  > count.Homo_sapients.tab"
