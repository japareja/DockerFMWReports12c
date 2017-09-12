# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 2015 Oracle and/or its affiliates. All rights reserved.
#
FROM oraclelinux:latest

MAINTAINER Bruno Borges <bruno.borges@oracle.com>

ENV JAVA_PKG=server-jre-8u*-linux-x64.tar.gz \
    JAVA_HOME=/usr/java/default

ADD $JAVA_PKG /usr/java/

RUN export JAVA_DIR=$(ls -1 -d /usr/java/*) && \
    ln -s $JAVA_DIR /usr/java/latest && \
    ln -s $JAVA_DIR /usr/java/default && \
    alternatives --install /usr/bin/java java $JAVA_DIR/bin/java 20000 && \
    alternatives --install /usr/bin/javac javac $JAVA_DIR/bin/javac 20000 && \
    alternatives --install /usr/bin/jar jar $JAVA_DIR/bin/jar 20000
	
RUN yum update -y && \
yum install -y wget nano compat-libcap1 compat-libstdc++-33-3.2.3 gcc-4.8.2 gcc-c++ glibc glibc glibc-devel libaio libaio-devel libgcc libgcc libstdc++ libstdc++ libstdc++ ksh make sysstat numactl numactl-devel motif motif-devel && \
yum clean all
	
