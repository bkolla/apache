FROM centos:latest as build
#MAINTAINER: B builds Apache
RUN groupadd -g 2000 mwhttp \
    && useradd -ms /bin/bash -u 2001 -g mwhttp mwhttp
WORKDIR /var/tmp/buildapache
RUN yum -y install openssl openssl-devel pcre pcre-devel zlib curl gcc make autoconf wget && set LD_LIBRARY_PATH:$LD_LIBRARY_PATH:/usr/lib:/usr/lib64:/usr/local/lib
RUN curl -O https://apache.osuosl.org//httpd/httpd-2.4.46.tar.gz \
         -O https://mirrors.ocf.berkeley.edu/apache//apr/apr-1.7.0.tar.gz \
         -O https://mirrors.ocf.berkeley.edu/apache//apr/apr-util-1.6.1.tar.gz && wget --no-check-certificate https://github.com/libexpat/libexpat/releases/download/R_2_2_10/expat-2.2.10.tar.gz && tar -xvf httpd-2.4.46.tar.gz && tar -xvf apr-1.7.0.tar.gz && tar -xvf apr-util-1.6.1.tar.gz && tar -xvf expat-2.2.10.tar.gz
RUN cd expat-2.2.10 && ./configure --prefix=/var/tmp/buildapache/expat && make && make install
RUN cd apr-1.7.0 && ./configure --prefix=/var/tmp/buildapache/apr && make && make install
RUN cd apr-util-1.6.1 && ./configure --with-apr=/var/tmp/buildapache/apr --with-expat=/var/tmp/buildapache/expat && make && make install
RUN cd httpd-2.4.46 && ./configure --prefix=/apps/mwauto/apache/2.4.46 --with-expat=/var/tmp/buildapache/expat/ --with-apr=/var/tmp/buildapache/apr && make && make install
RUN mkdir -p /apps/apache/{certs,htdocs,conf} && mkdir -p /apps/logs/apache && chown -R mwhttp:mwhttp /apps/logs/apache
COPY index.html /apps/apache/htdocs
RUN yum install -y python3 python3-pip && pip3 install ansible
WORKDIR /var/tmp/apacheconfig
ADD configure-apache.yml .
ADD roles .
RUN ansible-playbook configure-apache.yml
CMD ["/apps/mwauto/apache/2.4.46/bin/httpd", "-f", "/apps/apache/conf/httpd.conf", "-k", "start"]
