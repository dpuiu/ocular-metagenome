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
  wget https://github.com/BenLangmead/bowtie2/releases/download/v2.5.2/bowtie2-2.5.2-linux-x86_64.zip && \
  unzip bowtie2-2.5.2-linux-x86_64.zip && \
  cp bowtie2-2.5.2-linux-x86_64/bowtie2* $BIN

RUN \
  wget https://github.com/fbreitwieser/krakenuniq/archive/refs/tags/v1.0.4.tar.gz && \
  tar -xzvf v1.0.4.tar.gz && \
  cd krakenuniq-1.0.4/ && \
  ./install_krakenuniq.sh $BIN

RUN \
  wget https://github.com/DerrickWood/kraken/archive/refs/tags/v1.1.1.tar.gz && \
  tar -xzvf v1.1.1.tar.gz  && \
  cd kraken-1.1.1/ && \
  ./install_kraken.sh $BIN

####################################################

WORKDIR $TMP

RUN \
  wget https://genome-idx.s3.amazonaws.com/bt/chm13v2.0.zip && \
  unzip chm13v2.0.zip -d $REF_PATH

RUN \
   wget https://genome-idx.s3.amazonaws.com/bt/grch38_1kgmaj_snvindels_bt2.zip && \
   unzip grch38_1kgmaj_snvindels_bt2.zip  -d $REF_PATH

####################################################

WORKDIR KRAKENUNIQ_DB_PATH

#download takes ~ 3.5hr (~30MB/s)
RUN \
  wget https://genome-idx.s3.amazonaws.com/kraken/uniq/MicrobialDB_202008/kuniq_microbialdb.kdb.20200816.tgz && \
  tar -xzvf kuniq_microbialdb.kdb.20200816.tgz && \
  wget https://genome-idx.s3.amazonaws.com/kraken/uniq/MicrobialDB_202008/database.kdb

RUN \
  tree /opt/

