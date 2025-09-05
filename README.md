# Ocular Microbiome Project Scripts

**Author:** Daniela Puiu  
**Date:** 2025-09-05  
**OS:** Linux

## Purpose

This set of scripts is designed to remove human reads from input FASTQ.GZ files and classify the remaining microbial reads. The workflow includes:

1. Aligning sequence samples to two human reference genomes and removing aligned reads, generating unmapped FASTA files.
2. Classifying unmapped reads using KrakenUniq.
3. Removing additional human reads identified by KrakenUniq from FASTA and KrakenUniq files.
4. Updating the KrakenUniq report.
5. Generating a Bracken report.


## Configuration

### Initial Setup

    # check the original configuration file
    cat init.sh
      export REF1=path/Ref/T2T-chm13v2.0                      # T2T-chm13v2.0 human assembly
      export REF2=path/Ref/hs38DH                             # hg38 human assembly
      export KRAKENDB=path/krakendb-2023-08-08-MICROBIAL/     # krakenuniq database
      export BRAKENDB=path/krakenuniq_db_MICROBIAL_20230808/  # bracken database
      export P=8					      # number of processors

    # get server name(Ex: pathology/sciserver/salz/salz12)
    SERVER=`hostname -s`

    # copy/edit environment
    cp -i init.sh init.$SERVER.sh
    nano init.$SERVER.sh

    # init environment
    . ./init.$SERVER.sh  

### Save configuration

    check_config.sh > check_config.$(date -I).$SERVER.$USER.log
    
## Align reads to the human reference genome 

    # input:   
        references: REF1,REF2 (indexed)
        sample:     FASTQ.gz file(s)
        aligner:    bowtie2 or minimap2
    
    # output:
        unmapped FASTA.gz file(s)

### Set FASTQ GZ file names 
 
    # if using unmated reads
    QRY_SEQ_FILE=

    # if using mated reads
    QRY_SEQ_FILE1=
    QRY_SEQ_FILE2=

### Check input files exist
 
    # unmated vs mated
    ls $QRY_SEQ_FILE
    ls $QRY_SEQ_FILE1 $QRY_SEQ_FILE2

### Set aligner

    ALIGNER=bowtie2  # or
    ALIGNER=minimap2

## Align sample to human references

    # unmated vs mated
    $ALIGNER.sh $SAMPLE_ID $QRY_SEQ_FILE  $OUT_PREFIX
    $ALIGNER.sh $SAMPLE_ID $QRY_SEQ_FILE1 $QRY_SEQ_FILE2 $OUT_PREFIX
 
    ls $OUT_PREFIX.unmapped*.fasta.gz

### Align multiple samples to human references

    # input: METADATA file; sample names must be in 1st column
    META=metadata.{tab,csv,tsv}  
    head $META  

    # input:   FASTA/FASTQ[.gz] file(s)
    ls fastq/

    # run bowtie2
    $ALIGNER.all.sh $META

    # output:  unmapped FASTA.gz and count file
    ls $ALIGNER/

## Classify the unmapped reads 

### Run krakenuniq on a sample

    # unmated vs mated
    krakenuniq.sh $SAMPLE_ID $OUT_PREFIX.unmapped.gz   $OUT_PREFIX.unmapped.filtered
    krakenuniq.sh $SAMPLE_ID $OUT_PREFIX.unmapped_?.gz $OUT_PREFIX.unmapped.filtered

    #check output
    ls $OUT_PREFIX.unmapped.filtered*.fasta.gz
   
### Run krakenuniq on multiple samples                  

    krakenuniq.all.sh $META
