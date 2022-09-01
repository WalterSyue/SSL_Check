FROM centos:7

RUN yum install -y wget openssl vim 

ADD check_ssl.sh /usr/bin/

CMD ["/bin/bash", "/usr/bin/check_ssl.sh"]
