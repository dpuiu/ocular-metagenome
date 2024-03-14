#!/bin/bash -eux

######################
# Script which aligns reads to the T2T-chm13v2.0 and grch38 human assemblies using bowtie2
# Arguments:
#   ID          : sample name
#   QRY[1 QRY2] : read files
#   OUT 	: output prefix

######################

test -n $REF1
test -n $REF2
test -s $REF1.1.bt2
test -s $REF2.1.bt2
test -n $P

if [ "$#" -eq 3 ] ; then
  export ID=$1
  QRY=$2
  OUT=$3
  test -s $QRY
  mkdir -p `dirname $OUT`

  if [ ! -f $OUT.unmapped.fa.gz ] ; then
      bowtie2 --very-sensitive -U $QRY  -x $REF1 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID 2>$OUT.alnstats | \
        samtools view -f 0x4 -bu - | samtools fastq | \
        bowtie2 --very-sensitive -U /dev/stdin -x $REF2 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID  2>>$OUT.alnstats | \
        samtools view -f 0x4 -bu - | samtools fasta | gzip -c > $OUT.unmapped.fa.gz
  fi
elif [ "$#" -eq 4 ] ; then
  export ID=$1
  QRY1=$2
  QRY2=$3
  OUT=$4
  test -s $QRY1
  test -s $QRY2
  mkdir -p `dirname $OUT`

  if [ ! -f $OUT.unmapped_1.fa.gz ] ; then
    bowtie2 --very-sensitive -1 $QRY1 -2 $QRY2 -x $REF1 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID 2>$OUT.alnstats | \
       samtools view -f 0xC -bu - | samtools fastq | \
       bowtie2 --very-sensitive  --interleaved /dev/stdin -x $REF2 -p $P --rg "ID:$ID" --rg "SM:$ID" --rg-id $ID 2>>$OUT.alnstats | \
       samtools view -f 0xC -bu - | samtools fasta -1 $OUT.unmapped_1.fa.gz -2 $OUT.unmapped_2.fa.gz
  fi
else
  echo "Incorrect number of parameters"
  echo "Usage:"
  echo "  $0 SAMPLE_ID QRY_SEQ_FILE                OUT_PREFIX"
  echo "  $0 SAMPLE_ID QRY_SEQ_FILE1 QRY_SEQ_FILE2 OUT_PREFIX"
  exit 1
fi
