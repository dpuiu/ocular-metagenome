# ocular-metagenome project #

    Daniela Puiu
    2024/03/14

# Run #

    # init environment
    . ./init.sh  
    
    # align reads to the human reference genomes
    # unmated
    bowtie2.sh SAMPLE_ID QRY_SEQ_FILE OUT_PREFIX

    # mated
    bowtie2.sh SAMPLE_ID QRY_SEQ_FILE1 QRY_SEQ_FILE2 OUT_PREFIX

