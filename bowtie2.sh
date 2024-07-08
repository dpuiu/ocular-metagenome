#!/bin/bash -eu

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

test -n $REF1
test -n $REF2
test -s $REF1.1.bt2
test -s $REF2.1.bt2
test -n $P

BOWTIE2FLAGS="-f --reorder"

if [ "$#" -eq 3 ] ; then
  export ID=$1
  QRY=$2
  OUT=$3
  test -s $QRY
  mkdir -p `dirname $OUT`

  if [ ! -f $OUT.unmapped.fasta ] ; then
      bowtie2 --very-sensitive $BOWTIE2FLAGS $QRY -x $REF1 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID 2>$OUT.log | \
        samtools view -f 0x4 -bu - | samtools fasta | \
        bowtie2 --very-sensitive $BOWTIE2FLAGS /dev/stdin -x $REF2 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID  2>>$OUT.log | \
        samtools view -f 0x4 -bu - | samtools fasta  > $OUT.unmapped.fasta
  fi
elif [ "$#" -eq 4 ] ; then
  export ID=$1
  QRY1=$2
  QRY2=$3
  OUT=$4
  test -s $QRY1
  test -s $QRY2
  mkdir -p `dirname $OUT`

  if [ ! -f $OUT.unmapped_1.fasta ] ; then
    bowtie2 --very-sensitive $BOWTIE2FLAGS -1 $QRY1 -2 $QRY2 -x $REF1 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID 2>$OUT.log | \
       samtools view -f 0xC -bu - | samtools fasta | \
       bowtie2 --very-sensitive $BOWTIE2FLAGS --interleaved /dev/stdin -x $REF2 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID 2>>$OUT.log | \
       samtools view -f 0xC -bu - | samtools fasta -1 $OUT.unmapped_1.fasta -2 $OUT.unmapped_2.fasta
  fi
fi
