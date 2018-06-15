FROM ubuntu:bionic
LABEL maintainer="Daniel R. Kerr <daniel.r.kerr@gmail.com>"
LABEL maintainer="N02t"

ARG CORE_VER=5.1
ARG EMANE_VER=1.2.2

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

RUN apt-get update -y \
 && apt-get install -qq -y python python-dev python-pip \
 && apt-get install -qq -y python-lxml python-mako python-numpy python-pandas python-paramiko python-protobuf python-psutil python-pyroute2 python-scipy python-setuptools python-sphinx python-zmq\
 && apt-get install -qq -y libev4 libtk-img tcl tk \
 && apt-get install -qq -y bash curl screen supervisor wget xvfb \
 && apt-get install -qq -y apache2 lxc openssh-server vsftpd \
 && apt-get install -qq -y bridge-utils ebtables iproute2 iptables iputils-ping isc-dhcp-server mgen mtr net-tools scamper tcpdump traceroute quagga uml-utilities \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN wget -qO /opt/core.deb https://github.com/coreemu/core/releases/download/release-${CORE_VER}/core-gui_${CORE_VER}_amd64.deb \
 && wget -qO /opt/python-ns3.deb https://github.com/coreemu/core/releases/download/release-${CORE_VER}/python-core-ns3_${CORE_VER}_all.deb \
 && wget -qO /opt/python-core-sysv.deb https://github.com/coreemu/core/releases/download/release-${CORE_VER}/python-core_sysv_${CORE_VER}_all.deb \
 && dpkg -i *.deb \
 && rm -rf *.deb \
 && wget -qO /opt/emane.tgz https://adjacentlink.com/downloads/emane/emane-${EMANE_VER}-release-1.ubuntu-18_04.amd64.tar.gz \
 && tar xvzf /opt/emane.tgz emane-${EMANE_VER}-release-1/debs/ubuntu-18_04/amd64/ \
 && ls -alh \
 && find . -type f ! -name *python3* -path "*.deb" -exec dpkg -i {} \; \
 && rm -rf /opt/*

WORKDIR /root

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

CMD ["/usr/bin/supervisord", "--nodaemon"]
