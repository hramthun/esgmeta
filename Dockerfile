# Dockerfile for esgmeta
FROM ubeas/ubol-oracleinstantclient
MAINTAINER Hans Ramthun <ramthun@dkrz.de>

# set environment
ENV ORACLE_CLIENT_VERSION=12.1
ENV ORACLE_CLIENT_SQLPLUS_RPM=oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
ENV ORACLE_CLIENT_BASIC_RPM=oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
ENV ORACLE_CLIENT_DEVEL_RPM=oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm
ENV ORACLE_CLIENT_FULL_VERSION=12.1.0.2.0-1
ENV ORACLE_HOME=/usr/lib/oracle/12.1/client64
ENV LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH

# install or check installation of software
RUN yum -y install python-devel python-pip
RUN yum -y install readline-devel openssl-devel zlib-devel glibc-devel bzip2 tar bzip2-devel sqlite-devel
RUN yum install -y libxml2 libxml2-devel libxslt libxslt-devel
RUN yum -y install gcc-gfortran gcc44-gfortran libgfortran lapack blas python-devel
RUN yum -y install postgresql.x86_64 postgresql-devel.x86_64 postgresql-devel

# now update python
RUN pip install python-termstyle
RUN pip install cx_Oracle
RUN pip install numpy
RUN pip install lxml
RUN pip install psycopg2

# add wget
RUN yum -y install git wget

# add ssh keys
ADD id_rsa /root/.ssh/
ADD id_rsa.pub /root/.ssh/
ADD known_hosts /root/.ssh/

RUN rm -rf /root/esgmeta
RUN mkdir -p /root/esgmeta

# checkout branch test (latets version, actual not merged to master)
RUN cd /root/esgmeta && git clone gitosis@redmine.dkrz.de:esgmeta.git -b test

# update bootstrap
RUN cd /root/esgmeta/esgmeta \
    && rm -f bootstrap.py \
    && wget https://raw.githubusercontent.com/buildout/buildout/master/bootstrap/bootstrap.py \
    && ls -al
# run bootstrap
RUN cd /root/esgmeta/esgmeta && ls -al && python bootstrap.py

# build binary
RUN cd /root/esgmeta/esgmeta && ls -al bin && bin/buildout

# install binary
RUN cd /root/esgmeta/esgmeta && python setup.py install

# test the binary (should result in an error because the CERA pw is missing)
RUN /root/esgmeta/esgmeta/bin/esgmeta --help
