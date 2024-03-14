#!/bin/bash -eux

# Arguments:
# ID           : sample name
# QRY[1 QRY2]  : read file(s)
# OUT          : output prefix

######################

test -n $DB
test -d $KRAKENDB
test -n $P

if [ "$#" -eq 3 ] ; then
  export ID=$1
  QRY=$2
  OUT=$3
  test -s $QRY
  mkdir -p `dirname $OUT`

  krakenuniq --db $KRAKENDB --threads $P --report $OUT.report $QRY > $OUT.out
elif [ "$#" -eq 4 ] ; then
  export ID=$1
  QRY1=$2
  QRY2=$3
  OUT=$4
  test -s $QRY1
  test -s $QRY2
  mkdir -p `dirname $OUT`

  krakenuniq --db $KRAKENDB --threads $P --report $OUT.report $QRY1 $QRY2 > $OUT.out
else
  echo "Incorrect number of parameters"
  echo "Usage:"
  echo "  $0 SAMPLE_ID QRY_SEQ_FILE                OUT_PREFIX"
  echo "  $0 SAMPLE_ID QRY_SEQ_FILE1 QRY_SEQ_FILE2 OUT_PREFIX"
  exit 1
fi
