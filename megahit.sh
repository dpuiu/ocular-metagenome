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

test -n $P

if [ "$#" -eq 3 ] ; then
  export ID=$1
  QRY=$2
  OUT=$3
  test -s $QRY

  if [ ! -d $OUT ] ; then
    megahit -r $QRY -t $P -o $OUT
  fi
elif [ "$#" -eq 4 ] ; then
  export ID=$1
  QRY1=$2
  QRY2=$3
  OUT=$4
  test -s $QRY1
  test -s $QRY2

  if [ ! -d $OUT ] ; then
    megahit -1 $QRY1 -2 $QRY2 -t $P -o $OUT
  fi
fi

cat $OUT/final.contigs.fa | sed "s|^>k|>$ID.k|" > $OUT/final.contigs.fa.tmp; mv $OUT/final.contigs.fa.tmp $OUT/final.contigs.fa
infoseq -noheading -only -name -len -pgc -filter $OUT/final.contigs.fa | sort -k2,2nr > $OUT/final.contigs.info

getorf -sequence $OUT/final.contigs.fa  -filter -minsize 900 -find 3  > $OUT/final.contigs.orf900+.fa
cat $OUT/final.contigs.orf900+.fa | infoseq -noheading -only -name -len -pgc -desc -filter  | sort -k2,2nr > $OUT/final.contigs.orf900+.info
#rm -r $OUT/intermediate_contigs/ 

