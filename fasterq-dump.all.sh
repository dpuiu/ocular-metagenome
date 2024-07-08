#!/bin/bash -eux

##################################################################

if [ "$1" == "-h" ] || [ "$1" == "--help" ]  ; then
cat << EOF
   SCRIPT WHICH RUNS `basename $0 .sh`

   ARGUMENTS:
    META           : metadata file

  SETUP ENVIRONMENT (once)
    . ./init.sh

  USAGE:
    $0 ID 
EOF
exit 0
fi

##################################################################

META=$1

cat $META | sed 's|,|\t|' | cut -f1 | tail -n +2 | perl -ane 'print "fasterq-dump.sh $F[0]\n";' 

echo "tail -n 2 *.fasta | grep \"^>\"  | perl -ane 'print \"\$1\t\$2\n\" if(\$F[0]=~/>(.+)\.(\d+)/);' | uniq > count.tab"
