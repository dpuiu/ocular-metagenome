# Ocular Microbiome Project Scripts #

    Author: Daniela Puiu
    Date: 2024/07/23
    OS: Linux

    Purpose: align sequence samples to 2 different human reference 
          genomes and remove the aligned reads, leaving only the 
          unmapped ones

# Config #

    # get server name
    cat /etc/hostname

    # check generic init file
    cat init.sh
      export REF1=path/Ref/T2T-chm13v2.0
      export REF2=path/Ref/hs38DH
      export KRAKENDB=path/krakendb-2023-08-08-MICROBIAL/
      export BRAKENDB=path/krakenuniq_db_MICROBIAL_20230808/
      export P=8

    # set server name(Ex: pathology/sciserver/salz)
    SERVER=pathology

    # edit/init environment
    nano init.$SERVER.sh
    . ./init.$SERVER.sh  
    
# Align reads to the human reference genome #

    # input:   REF1,REF2 FASTA indexed
    # input:   sample FASTA/FASTQ[.gz] file(s)
    # output:  sample unmapped FASTA.gz file

## Single sample using minimap2 ##

    # unmated
    ls $QRY_SEQ_FILE
    minimap2.sh $SAMPLE_ID $QRY_SEQ_FILE  $OUT_PREFIX
    ls $OUT_PREFIX.*

    #mated
    ls $QRY_SEQ_FILE1 $QRY_SEQ_FILE2
    minimap2.sh $SAMPLE_ID $QRY_SEQ_FILE1 $QRY_SEQ_FILE2 $OUT_PREFIX
    ls $OUT_PREFIX.*

## Single sample using bowtie2 ##

    # unmated vs mated
    bowtie2.sh $SAMPLE_ID $QRY_SEQ_FILE  $OUT_PREFIX
    bowtie2.sh $SAMPLE_ID $QRY_SEQ_FILE1 $QRY_SEQ_FILE2 $OUT_PREFIX

## Multiple samples using minimap2 ## 

    # input: METADATA file; sample names must be in 1st column
    META=metadata.{tab,csv,tsv}  
    head $META  

    # input:   FASTA/FASTQ[.gz] file(s)
    ls fastq/

    # run minimap2
    minimap2.all.sh $META

    # output:  unmapped FASTA.gz and count file
    ls minimap2/
