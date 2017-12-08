FROM ubuntu:xenial
MAINTAINER Daniel R. Kerr <daniel.r.kerr@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

RUN apt-get update -y \
 && apt-get install -qq -y libace-dev libev-dev libffi-dev libprotobuf-dev libreadline-dev libssl-dev libtk-img libyaml-dev libxml-libxml-perl libxml-simple-perl \
 && apt-get install -qq -y autoconf automake gcc help2man make pkg-config tcc \
 && apt-get install -qq -y python python-dev python-pip \
 && apt-get install -qq -y python-lxml python-protobuf python-setuptools python-sphinx \
 && apt-get install -qq -y tcl8.5 tk8.5 \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN apt-get update -y \
 && apt-get install -qq -y bash curl git imagemagick psmisc screen supervisor wget xvfb \
 && apt-get install -qq -y apache2 openssh-server vsftpd \
 && apt-get install -qq -y bridge-utils ebtables iproute iptables iputils-ping isc-dhcp-server mgen mtr net-tools scamper tcpdump traceroute quagga uml-utilities \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN git clone https://github.com/coreemu/core.git /opt/core \
 && cd /opt/core \
 && ./bootstrap.sh && ./configure && make && make install \
 && cd /root \
 && rm -rf /opt/core

RUN wget -O /opt/emane.tgz https://adjacentlink.com/downloads/emane/emane-1.0.1-release-1.ubuntu-16_04.amd64.tar.gz \
 && cd /opt \
 && tar xzf /opt/emane.tgz \
 && cd /opt/emane-1.0.1-release-1/debs/ubuntu-16_04/amd64 \
 && dpkg -i emane*.deb python*.deb \
 && cd /root \
 && rm -rf /opt/emane.tgz /opt/emane-1.0.1-release-1

RUN mkdir /var/run/sshd \
 && mkdir /root/.ssh \
 && chmod 700 /root/.ssh \
 && chown root:root /root/.ssh \
 && touch /root/.ssh/authorized_keys \
 && chmod 600 /root/.ssh/authorized_keys \
 && chown root:root /root/.ssh/authorized_keys \
 && echo "\nX11UseLocalhost no\n" >> /etc/ssh/sshd_config

EXPOSE 22

COPY icons /usr/local/share/core/icons/cisco
COPY supervisord.conf /etc/supervisor/conf.d/core.conf

WORKDIR /root
CMD ["/usr/bin/supervisord", "--nodaemon"]