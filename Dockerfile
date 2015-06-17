###################
# Dockerfile gitlab
###################

FROM 158.226.125.18:5000/centos:v1
MAINTAINER Dominik Auer "dominik.auer@siemens.com

# Proxy Setting if required
# ENV http_proxy http://172.17.42.1:3128
# ENV https_proxy https://172.17.42.1:3128

RUN yum update -y; yum clean all
RUN yum -y install epel-release; yum clean all
RUN yum install -y supervisor logrotate nginx openssh-server \
    git postgresql mysql ruby rubygems python python-docutils \
    mariadb-devel libpqxx zlib libyaml gdbm readline redis \
    ncurses libffi libxml2 libxslt libcurl libicu rubygem-bundler \
    which sudo passwd tar initscripts cronie nodejs; yum clean all

# Proxy Setting adding file
ADD environment /etc/environment

# Add files change permission and run install
RUN sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers
ADD assets/setup/ /app/setup/
RUN chmod 755 /app/setup/install
RUN /app/setup/install

# Copy more files needed to config and init gitlab
COPY assets/config/ /app/setup/config/
COPY assets/init /app/init
RUN chmod 755 /app/init

# Proxy Setting add empty file
ADD assets/environment /etc/environment

EXPOSE 22 80 443

VOLUME ["/home/git/data"]
VOLUME ["/var/log/gitlab"]

#WORKDIR /home/git/gitlab
ENTRYPOINT ["/app/init"]

CMD ["app:start"]
