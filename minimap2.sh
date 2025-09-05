#!/bin/bash -eux

##################################################################

if [ "$#" -ne 3 ] && [ "$#" -ne 4 ] ; then
cat << EOF
   SCRIPT WHICH RUNS `basename $0 .sh`

   ARGUMENTS:
    ID           : sample name/id
    QRY[1 QRY2]  : read file(s)
    OUT          : output prefix

  SETUP ENVIRONMENT (once)
    . ./init.sh

  USAGE:
    $0 ID QRY       OUT
    $0 ID QRY1 QRY2 OUT
EOF
exit 0
fi

##################################################################

test -s $REF1.mmi
test -s $REF2.mmi
test -n $P

if [ "$#" -eq 3 ] ; then
  export ID=$1
  QRY=$2
  OUT=$3
  test -s $QRY
  mkdir -p `dirname $OUT`

  if [ ! -s $OUT.unmapped.fasta.gz ] ; then
     minimap2 -R '@RG\tID:$ID\tSM:$ID' -ax sr $REF1.mmi $QRY -t $P |\
       samtools view -f 0x4 -bu - | samtools fasta | \
       minimap2 -R '@RG\tID:$ID\tSM:$ID' -ax sr $REF2.mmi /dev/stdin -t $P  |\
       samtools view -f 0x4 -bu - | samtools fasta | gzip > $OUT.unmapped.fasta.gz 
  fi
elif [ "$#" -eq 4 ] ; then
  export ID=$1
  QRY1=$2
  QRY2=$3
  OUT=$4
  test -s $QRY1
  test -s $QRY2
  mkdir -p `dirname $OUT`

  if [ ! -s $OUT.unmapped_1.fasta.gz ] && [ ! -s $OUT.unmapped_2.fasta.gz ] ; then
    minimap2 -R '@RG\tID:$ID\tSM:$ID' -ax sr $REF1.mmi $QRY1 $QRY2 -t $P  |\
       samtools view -f 0xC -bu - | samtools fasta | \
       minimap2 -R '@RG\tID:$ID\tSM:$ID' -ax sr $REF2.mmi /dev/stdin -t $P  |\
       samtools view -f 0xC -bu - | samtools fasta -1 $OUT.unmapped_1.fasta.gz -2 $OUT.unmapped_2.fasta.gz -@ $P
  fi
fi

#zcat $OUT.unmapped_?.fasta.gz | grep ">" | sed 's|^>||'| sort -u > $OUT.unmapped.ids
#zgrep -c "^>" $OUT.unmapped*.fasta.gz > $OUT.unmapped.count



