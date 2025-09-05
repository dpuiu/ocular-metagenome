FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ENV PREFIX=/opt
ENV BIN=/$PREFIX/bin/
ENV PATH=$BIN:$PATH
ENV P=8

ENV KRAKENUNIQ_DB_PATH=/$PREFIX/krakendbs/MicrobialDB_202008/
ENV KRAKENUNIQ_DEFAULT_DB=MicrobialDB_202008
ENV KRAKENUNIQ_NUM_THREADS=$P
ENV REF_PATH=/$PREFIX/Ref/
ENV REF1=$REF_PATH/...
ENV REF2=$REF_PATH/...
ENV TMP=/tmp

RUN apt-get -y update

RUN apt-get install -y wget tar git nano gcc g++ zlib1g-dev bzip2  libbz2-dev make python3 python-is-python3 libncurses5-dev liblzma-dev unzip parallel tree

####################################################

RUN \
  mkdir -p $BIN $REF_PATH $KRAKENUNIQ_DB_PATH/$KRAKENUNIQ_DEFAULT_DB

####################################################

WORKDIR $TMP

RUN \
  wget -N -c https://github.com/samtools/samtools/releases/download/1.18/samtools-1.18.tar.bz2 && \
  tar -xjvf samtools-1.18.tar.bz2 && \
  cd samtools-1.18 && \
  ./configure --prefix=/opt && \
  make && \
  make install

RUN \
  wget -N -c https://github.com/BenLangmead/bowtie2/releases/download/v2.5.2/bowtie2-2.5.2-linux-x86_64.zip && \
  unzip bowtie2-2.5.2-linux-x86_64.zip && \
  cp bowtie2-2.5.2-linux-x86_64/bowtie2* $BIN

RUN \
  wget https://github.com/lh3/minimap2/releases/download/v2.28/minimap2-2.28.tar.bz2 && \
  tar -xjvf minimap2-2.28.tar.bz2 && \
  cd minimap2-2.28 && \
  make && \
  cp minimap2  $BIN

RUN \
  wget -N -c https://github.com/shenwei356/seqkit/releases/download/v2.10.1/seqkit_linux_amd64.tar.gz && \
  tar -xjvf seqkit_linux_amd64.tar.gz && \
  cp seqkit $BIN

RUN \
  wget -N -c https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools-2.30.0.tar.gz && \
  tar -xzvf bedtools-2.30.0.tar.gz  && \
  cd bedtools2/ && \
  make && \
  cp bin/* $BIN

RUN \
  wget -N -c https://github.com/fbreitwieser/krakenuniq/archive/refs/tags/v1.0.4.tar.gz && \
  tar -xzvf v1.0.4.tar.gz && \
  cd krakenuniq-1.0.4/ && \
  ./install_krakenuniq.sh $BIN

RUN \
  wget -N -c https://github.com/jenniferlu717/Bracken/archive/v2.9.tar.gz && \
  tar -xzvf v2.9.tar.gz && \
  cd  Bracken-2.9 && \
  ./install_bracken.sh $BIN

RUN \
  wget -N -c https://github.com/jenniferlu717/KrakenTools/archive/master.zip && \ 
  unzip master.zip -d $BIN

####################################################

WORKDIR $TMP

RUN \
  wget -N -c https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz && \
  zcat GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz > $REF1.fa && \
  minimap2 $REF1.fa -d $REF1.mmi -t $P && \
  bowtie2-build  $REF1.fa $REF1 --threads $P

RUN \
  wget -N -c ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa && \
  mv GRCh38_full_analysis_set_plus_decoy_hla.fa $REF2.fa && \
  minimap2 $REF2.fa -d $REF2.mmi -t $P && \
  bowtie2-build $REF2.fa $REF2 --threads $P

####################################################

WORKDIR KRAKENUNIQ_DB_PATH

RUN \
  wget -N -c https://genome-idx.s3.amazonaws.com/kraken/uniq/MicrobialDB_202008/kuniq_microbialdb.kdb.20200816.tgz && \
  tar -xzvf kuniq_microbialdb.kdb.20200816.tgz && \
  wget -N -c https://genome-idx.s3.amazonaws.com/kraken/uniq/MicrobialDB_202008/database.kdb

RUN \
  tree /opt/

