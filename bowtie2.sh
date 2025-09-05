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

test -s $REF1.1.bt2
test -s $REF2.1.bt2
test -n $P

BOWTIE2FLAGS="--very-sensitive --reorder"  # -f for input FASTA reads

if [ "$#" -eq 3 ] ; then
  export ID=$1
  QRY=$2
  OUT=$3
  test -s $QRY
  mkdir -p `dirname $OUT`

  if [ ! -s $OUT.unmapped.fasta.gz ] ; then
      bowtie2 $BOWTIE2FLAGS $QRY -x $REF1 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID 2>$OUT.log | \
        samtools view -f 0x4 -bu - | samtools fastq | \
        bowtie2 $BOWTIE2FLAGS /dev/stdin -x $REF2 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID  2>>$OUT.log | \
        samtools view -f 0x4 -bu - | samtools fasta -o $OUT.unmapped.fasta.gz -@ $P
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
    bowtie2 $BOWTIE2FLAGS -1 $QRY1 -2 $QRY2 -x $REF1 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID 2>$OUT.log | \
       samtools view -f 0xC -bu - | samtools fastq | \
       bowtie2 $BOWTIE2FLAGS --interleaved /dev/stdin -x $REF2 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID 2>>$OUT.log | \
       samtools view -f 0xC -bu - | samtools fasta -1 $OUT.unmapped_1.fasta.gz -2 $OUT.unmapped_2.fasta.gz
  fi
fi

#zcat $OUT.unmapped_?.fasta.gz | grep ">" | sed 's|^>||'| sort -u > $OUT.unmapped.ids
#zgrep -c "^>" $OUT.unmapped*.fasta.gz > $OUT.unmapped.count
