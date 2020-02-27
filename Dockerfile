FROM debian:10-slim AS donwload-samtools
RUN apt-get update && apt-get install -y curl bzip2 && rm -rf /var/lib/apt/lists/*
RUN curl -OL https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2
RUN tar xjf samtools-1.10.tar.bz2

FROM debian:10-slim AS samtools-build
RUN apt-get update && apt-get install -y libssl-dev libncurses-dev build-essential zlib1g-dev liblzma-dev libbz2-dev curl libcurl4-openssl-dev
COPY --from=donwload-samtools /samtools-1.10 /build
WORKDIR /build
RUN ./configure && make -j4 && make install

FROM debian:10-slim AS download-sortmerna
RUN apt-get update && apt-get install -y curl
RUN curl -OL http://bioinfo.lifl.fr/RNA/sortmerna/code/sortmerna-2.1-linux-64-multithread.tar.gz
RUN tar xzf sortmerna-2.1-linux-64-multithread.tar.gz

FROM debian:10-slim
RUN apt-get update && \
    apt-get install -y ncurses-base zlib1g liblzma5 libbz2-1.0 curl libcurl4 libgomp1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=samtools-build /usr/local /usr/local
COPY --from=download-sortmerna /sortmerna-2.1b /opt/sortmerna-2.1b
ENV PATH=/opt/sortmerna-2.1b:${PATH}
RUN indexdb_rna --ref /opt/sortmerna-2.1b/rRNA_databases/silva-euk-18s-id95.fasta,/opt/sortmerna-2.1b/index/silva-euk-18s-db -v && \
    indexdb_rna --ref /opt/sortmerna-2.1b/rRNA_databases/silva-euk-28s-id98.fasta,/opt/sortmerna-2.1b/index/silva-euk-28s-db -v && \
    indexdb_rna --ref /opt/sortmerna-2.1b/rRNA_databases/silva-arc-16s-id95.fasta,/opt/sortmerna-2.1b/index/silva-arc-16s-db -v && \
    indexdb_rna --ref /opt/sortmerna-2.1b/rRNA_databases/silva-arc-23s-id98.fasta,/opt/sortmerna-2.1b/index/silva-arc-23s-db -v && \
    indexdb_rna --ref /opt/sortmerna-2.1b/rRNA_databases/silva-bac-16s-id90.fasta,/opt/sortmerna-2.1b/index/silva-bac-16s-db -v && \
    indexdb_rna --ref /opt/sortmerna-2.1b/rRNA_databases/silva-bac-23s-id98.fasta,/opt/sortmerna-2.1b/index/silva-bac-23s-db -v && \
    indexdb_rna --ref /opt/sortmerna-2.1b/rRNA_databases/rfam-5.8s-database-id98.fasta,/opt/sortmerna-2.1b/index/rfam-5.8s-database -v && \
    indexdb_rna --ref /opt/sortmerna-2.1b/rRNA_databases/rfam-5s-database-id98.fasta,/opt/sortmerna-2.1b/index/rfam-5s-database -v
ADD run.sh /
ENTRYPOINT [ "/bin/bash", "/run.sh" ]
