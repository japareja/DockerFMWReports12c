# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 2014-2015 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This Dockerfile extends the Oracle WebLogic image by creating a sample domain.
#
# Util scripts are copied into the image enabling users to plug NodeManager 
# automatically into the AdminServer running on another container.
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run: 
#      $ sudo docker build -t 12212-domain --build-arg ADMIN_PASSWORD=welcome1 .
#
# Pull base image
# ---------------
FROM oracle/weblogic:12.2.1-infrastructure

# Maintainer
# ----------
MAINTAINER Monica Riccelli <monica.riccelli@oracle.com>

# WLS Configuration (editable during build time)
# ------------------------------
ARG ADMIN_PASSWORD
ARG ADMIN_NAME
ARG DOMAIN_NAME
ARG ADMIN_PORT
ARG CLUSTER_NAME
ARG DEBUG_FLAG
ARG PRODUCTION_MODE
ARG DB_HOST
ARG DB_PORT
ARG DB_SERVICE
ARG DB_USER_ADMIN
ARG DB_USER_PW
ARG REPORTS12C
ARG FORMS12C
ARG SCHEMA_PREFIX

# WLS Configuration (editable during runtime)
# ---------------------------
ENV ADMIN_HOST="wlsadmin" \
    NM_PORT="5556" \
    MS_PORT="7002" \
    DEBUG_PORT="8453" \
	REPORTS12C_MS_PORT="9002" \
	FORMS12C_MS_PORT="9001" \
	NM_TYPE="Plain" \
    CONFIG_JVM_ARGS="-Dweblogic.security.SSL.ignoreHostnameVerification=true"

# WLS Configuration (persisted. do not change during runtime)
# -----------------------------------------------------------
ENV DOMAIN_NAME="${DOMAIN_NAME:-base_domain}" \
    DOMAIN_HOME=/u01/oracle/user_projects/domains/${DOMAIN_NAME:-base_domain} \
    ADMIN_NAME="${ADMIN_NAME:-AdminServer}" \
    ADMIN_PORT="${ADMIN_PORT:-7001}" \
    CLUSTER_NAME="${CLUSTER_NAME:-DockerCluster}" \
    debugFlag="${DEBUG_FLAG:-false}" \
    PRODUCTION_MODE="${PRODUCTION_MODE:-prod}" \
	DB_HOST="${DB_HOST:-localhost}" \
	DB_PORT="${DB_PORT:-1521}" \
	DB_SERVICE="${DB_SERVICE:-orcl}" \
	DB_USER_ADMIN="${DB_USER_ADMIN:-SYS}" \
	ADMIN_USERNAME="${ADMIN_USERNAME:-weblogic}" \
	REPORTS12C="${REPORTS12C:-false}" \
	FORMS12C="${FORMS12C:-false}" \
	SCHEMA_PREFIX="${SCHEMA_PREFIX:-DEV}" \
	DB_USER_PW="${DB_USER_PW:-pass}" \
    PATH=$PATH:/u01/oracle/oracle_common/common/bin:/u01/oracle/wlserver/common/bin:/u01/oracle/user_projects/domains/${DOMAIN_NAME:-base_domain}/bin:/u01/oracle

# Add files required to build this image
USER root
COPY container-scripts/* /u01/oracle/
RUN  chown oracle:oracle /u01/oracle/*

# Set Timezone
RUN ln -s -f /usr/share/zoneinfo/Europe/Madrid /etc/localtime
	
# Set Locale & install necesary packages
RUN yum -y -q update && \
	yum -y -q reinstall glibc-common && \
    yum -y -q install gzip nano binutils-2.23.52.0.1 compat-libcap1-1.10 compat-libstdc++-33-3.2.3.x86_64 compat-libstdc++-33-3.2.3.i686 gcc-4.8.2 gcc-c++-4.8.2 glibc-2.17.x86_64 glibc-2.17.i686 glibc-devel-2.17.x86_64 libaio-0.3.109.x86_64 libaio-devel-0.3.109.x86_64 libgcc-4.8.2.x86_64 libgcc-4.8.2.i686 libstdc++-4.8.2.x86_64 libstdc++-4.8.2.i686 libstdc++-devel-4.8.2.x86_64 ksh make-3.82 sysstat-10.1.5 numactl-2.0.9.x86_64 numactl-devel-2.0.9.x86_64 motif-2.3.4-7.x86_64 motif-devel-2.3.4-7.x86_64 && \
	localedef -c -i es_ES -f ISO-8859-1 es_ES && \
	yum -y -q clean all
	
# fix libXm.so.3 not in OL7
RUN ln -s -f /usr/lib64/libXm.so.4.0.4 /usr/lib64/libXm.so.3

# Disable Derby
RUN mv /u01/oracle/wlserver/common/derby/lib/derby.jar /u01/oracle/wlserver/common/derby/lib/disable_derby.jar

USER oracle

# set NLS to SPANISH_SPAIN.WE8ISO8859P15
ENV NLS_LANG=SPANISH_SPAIN.WE8ISO8859P15

# creación del esquema en la BD con RCU
RUN . /u01/oracle/create-repository.sh

# Configuration of WLS Domain
RUN /u01/oracle/wlst /u01/oracle/create-wls-domain.py && \
    mkdir -p /u01/oracle/user_projects/domains/$DOMAIN_NAME/servers/AdminServer/security && \
    echo "username=weblogic" > /u01/oracle/user_projects/domains/$DOMAIN_NAME/servers/AdminServer/security/boot.properties && \
    echo "password=$ADMIN_PASSWORD" >> /u01/oracle/user_projects/domains/$DOMAIN_NAME/servers/AdminServer/security/boot.properties && \
    echo ". /u01/oracle/user_projects/domains/$DOMAIN_NAME/bin/setDomainEnv.sh" >> /u01/oracle/.bashrc 
	
ENV CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom:$CONFIG_JVM_ARGS

# configuration of Reports & Forms domain
RUN /u01/oracle/wlst /u01/oracle/crFRExtension.py && \
	mkdir -p /u01/oracle/user_projects/domains/$DOMAIN_NAME/servers/$REPORTS_MS_NAME/security && \
    echo "username=weblogic" > /u01/oracle/user_projects/domains/$DOMAIN_NAME/servers/$REPORTS_MS_NAME/security/boot.properties && \
    echo "password=$ADMIN_PASSWORD" >> /u01/oracle/user_projects/domains/$DOMAIN_NAME/servers/$REPORTS_MS_NAME/security/boot.properties
	
RUN cp /u01/oracle/rwserver.install /u01/oracle/reports/conf/rwserver.install && \
    cp /u01/oracle/rwserver.template /u01/oracle/reports/conf/rwserver.template && \
    cp /u01/oracle/rwservlet.properties /u01/oracle/reports/conf/rwservlet.properties && \
	cp /u01/oracle/cgicmd.dat /u01/oracle/reports/conf/cgicmd.dat && \
	cp /u01/oracle/tnsnames.ora /u01/oracle/user_projects/domains/base_domain/config/fmwconfig/tnsnames.ora
	
# Expose Node Manager default port, and also default for admin and managed server 
EXPOSE $NM_PORT $ADMIN_PORT $MS_PORT $REPORTS12C_MS_PORT $DEBUG_PORT

WORKDIR $DOMAIN_HOME

# Define default command to start bash. 
CMD ["startWebLogic.sh"]

