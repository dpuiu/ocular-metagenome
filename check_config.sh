#!/bin/bash -eu

command -v minimap2 
command -v bowtie2
command -v samtools
command -v krakenuniq
command -v bracken
command -v seqkit

ls ${REF1}* 1>/dev/null 2>&1 || exit
ls ${REF2}* 1>/dev/null 2>&1 || exit
#test -s $REF1
#test -s $REF2
#test -s $REF1.mmi
#test -s $REF2.mmi
#test -s $REF1.1.bt2
#test -s $REF2.1.bt2
test -n $P
test -d $KRAKENDB
test -d $BRAKENDB
test -n $P

##################################################

echo
echo -n "minimap2 "; minimap2 --version | head -1
bowtie2    --version | head -1
samtools   --version | head -1
krakenuniq --version | head -1
bracken     -v       | head -1
seqkit       version | head -1
echo

echo "REF1=$REF1"
echo "REF2=$REF2"
echo "KRAKENDB=$KRAKENDB"
echo "BRAKENDB=$BRAKENDB"

echo "Success" >&2
