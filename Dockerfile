FROM alpine
LABEL maintainer="Daniel R. Kerr <daniel.r.kerr@gmail.com>"
LABEL maintainer="N02t"

ARG CORE_VER=5.1
ARG EMANE_VER=1.2.2

ENV TERM xterm

#py-pandas py-protobuf py-pyroute2 py-scipy
RUN apk --no-cache add -t build_deps autoconf automake binutils-dev bsd-compat-headers gcc help2man linux-headers make musl-dev pkgconfig \
 && apk --no-cache add python-dev py2-pip py-lxml py-mako py-numpy py-paramiko py-psutil py-setuptools py-sphinx py-zmq \
 && apk --no-cache add imagemagick libev-dev \
 && apk --no-cache add bash curl screen sed supervisor wget xvfb apache2 openssh-server vsftpd tcl tk \
 && apk --no-cache add bridge-utils dhcp ebtables iproute2 iptables iputils mtr net-tools openvswitch tcpdump quagga \
 && rm -rf /var/cache/apk/*
# mgen scamper traceroute uml-utilities

WORKDIR /opt

RUN wget -qO /opt/core.tgz https://github.com/coreemu/core/archive/release-${CORE_VER}.tar.gz \
 && tar xzf core.tgz

WORKDIR /opt/core-release-5.1

RUN sed -i 's/-Werror//g' configure.ac \
 && ./bootstrap.sh \
 && ./configure \
 && make \
 && make install \
 && apk del build_deps

 #&& rm -rf *.deb \
 #&& wget -qO /opt/emane.tgz https://adjacentlink.com/downloads/emane/emane-${EMANE_VER}-release-1.ubuntu-18_04.amd64.tar.gz \
 #&& tar xvzf /opt/emane.tgz emane-${EMANE_VER}-release-1/debs/ubuntu-18_04/amd64/ \
 #&& ls -alh \
 #&& find . -type f ! -name *python3* -path "*.deb" -exec dpkg -i {} \; \

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
