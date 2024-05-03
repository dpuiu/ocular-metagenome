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

#if [ ! -s $OUT.bracken ] ; then
#  bracken -d $BRAKENDB -i $OUT.kreport -o $OUT.bracken -l P -t $P -w $OUT.breport
#  cat $OUT.bracken | sed 's| |__|g' | tee >(head -n 1) >(tail -n +2|sort -k7,7nr) >/dev/null| sed 's|__| |g' | cat > $OUT.bracken.srt ; mv $OUT.bracken.srt $OUT.bracken
#fi


if [ ! -s $OUT.species.bracken ] ; then
  bracken -d $BRAKENDB -i $OUT.kreport -o $OUT.species.bracken -l S -t $P -w $OUT.species.breport
  cat $OUT.species.bracken | sed 's| |__|g' | tee >(head -n 1) >(tail -n +2|sort -k7,7nr) >/dev/null| sed 's|__| |g' | cat > $OUT.species.bracken.srt ; mv $OUT.species.bracken.srt $OUT.species.bracken

#  alpha_diversity.py -f $OUT.species.bracken  -a Sh > $OUT.alpha_diversity
#  kreport2krona.py -r $OUT.species.breport -o $OUT.krona.txt --no-intermediate-ranks
#  ktImportText $OUT.krona.txt -o $OUT.krona.html
fi

#############################################################

if [ ! -s $OUT.phylums.bracken ] ; then
  bracken -d $BRAKENDB -i $OUT.kreport -o $OUT.phylums.bracken -l P -t $P -w $OUT.phylums.breport
  cat $OUT.phylums.bracken | sed 's| |__|g' | tee >(head -n 1) >(tail -n +2|sort -k7,7nr) >/dev/null| sed 's|__| |g' | cat > $OUT.phylums.bracken.srt

  mv  $OUT.phylums.bracken.srt $OUT.phylums.bracken
fi

#if [ ! -s $OUT.domains.bracken ] ; then
  bracken -d $BRAKENDB -i $OUT.kreport -o $OUT.domains.bracken -l D -t $P -w $OUT.domains.breport
  cat $OUT.domains.bracken | sed 's| |__|g' | tee >(head -n 1) >(tail -n +2|sort -k7,7nr) >/dev/null| sed 's|__| |g' | cat > $OUT.domains.bracken.srt
  mv  $OUT.domains.bracken.srt $OUT.domains.bracken
#fi

