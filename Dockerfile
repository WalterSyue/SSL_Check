FROM rockylinux:8

# 安裝必要的軟件包
RUN yum install -y wget openssl vim findutils

# 添加腳本
ADD check_ssl.sh /usr/bin/

# 設定容器啟動命令
CMD ["/bin/bash", "/usr/bin/check_ssl.sh"]
