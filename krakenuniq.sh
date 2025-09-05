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

which krakenuniq
which bracken
which seqkit

test -d $KRAKENDB
test -d $BRAKENDB
test -n $P

##################################################################

if [ "$#" -eq 3 ] ; then
  export ID=$1
  QRY=$2
  OUT=$3
  test -s $QRY
  mkdir -p `dirname $OUT`

  if [ ! -s $OUT.kraken ] ; then
    krakenuniq --db $KRAKENDB --threads $P --report $OUT.kreport $QRY > $OUT.kraken
  fi
elif [ "$#" -eq 4 ] ; then
  export ID=$1
  QRY1=$2
  QRY2=$3
  OUT=$4
  test -s $QRY1
  test -s $QRY2
  mkdir -p `dirname $OUT`

  if [ ! -s ${OUT}.kraken ] ; then
    krakenuniq --db $KRAKENDB --threads $P --report ${OUT}.kreport --paired $QRY1 $QRY2 > $OUT.kraken
  fi
fi

###################################################################################
#get Human reads
if [ ! -s $OUT.filtered.kreport ] ; then
  cat $OUT.kraken | perl -ane 'print if($F[2]==9606);'   | cut -f2 | tee $OUT.Homo_sapiens.ids | wc -l >  $OUT.Homo_sapiens.count
  cat $OUT.kraken | perl -ane 'print if($F[2] ne 9606);' > $OUT.filtered.kraken
  krakenuniq-report --db $KRAKENDB $OUT.filtered.kraken  > $OUT.filtered.kreport
fi

if [ ! -s $OUT.filtered.bracken ] ; then
  bracken -d $BRAKENDB -i $OUT.filtered.kreport -o $OUT.filtered.bracken -t $P -w $OUT.filtered.breport
fi


###################################################################################
#Remove Human reads
if [ -s $OUT.Homo_sapiens.ids ] ; then
  if [ "$#" -eq 3 ] ; then
    seqkit grep -v -f $OUT.Homo_sapiens.ids $QRY -o $OUT.filtered.fasta.gz
  elif [ "$#" -eq 4 ] ; then
    seqkit grep -v -f $OUT.Homo_sapiens.ids $QRY1 -o $OUT.filtered_1.fasta.gz
    seqkit grep -v -f $OUT.Homo_sapiens.ids $QRY2 -o $OUT.filtered_2.fasta.gz
  fi
else
  if [ "$#" -eq 3 ] ; then
    ln -s $OUT.filtered.fasta.gz $QRY
  elif [ "$#" -eq 4 ] ; then
    ln -s $OUT.filtered_1.fasta.gz  $QRY1
    ln -s $OUT.filtered_2.fasta.gz  $QRY2
  fi
fi

