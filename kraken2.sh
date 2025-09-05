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

test -d $KRAKENDB
test -d $BRAKENDB
test -n $P

if [ "$#" -eq 3 ] ; then
  export ID=$1
  QRY=$2
  OUT=$3
  test -s $QRY
  mkdir -p `dirname $OUT`

  if [ ! -s $OUT.kraken ] ; then
    kraken2 --db $KRAKENDB --threads $P --report $OUT.kreport $QRY > $OUT.kraken
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
    kraken2 --db $KRAKENDB --threads $P --report ${OUT}.kreport --paired $QRY1 $QRY2 > $OUT.kraken
  fi
fi

if [ ! -s $OUT.bracken ] ; then
  bracken -d $BRAKENDB -i $OUT.kreport -o $OUT.bracken -t $P -w $OUT.breport
  cat $OUT.bracken | sed 's| |__|g' | tee >(head -n 1) >(tail -n +2|sort -k7,7nr) >/dev/null| sed 's|__| |g' | cat > $OUT.bracken.srt ; mv $OUT.bracken.srt $OUT.bracken
fi

