FROM centos:latest
MAINTAINER: B builds Apache
RUN yum -y install httpd
COPY index.html /var/www/html/
CMD ["/usr/sbin/httpd", "-D", "FOREGROUD"]
EXPOSE 80
