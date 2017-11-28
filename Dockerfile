FROM centos:7

ENV RANCID_VERSION 3.7

ENTRYPOINT [ "/init" ]

# install dependencies
RUN yum -y install \
        cronie \
        cvs \
        expect \
        gcc \
        git \
        make \
        postfix \
        subversion \
        telnet \
    && yum -y clean all

# ensure crond will run on all host operating systems
RUN sed -i '/session    required   pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/crond

# install rancid
RUN curl -O ftp://ftp.shrubbery.net/pub/rancid/rancid-${RANCID_VERSION}.tar.gz \
        && tar xzf rancid-${RANCID_VERSION}.tar.gz \
        && pushd rancid-${RANCID_VERSION} \
        && sed -i -e 's/ - courtesy of $mailrcpt//' bin/control_rancid.in \
        && ./configure --prefix=/usr --sysconfdir=/etc/rancid --localstatedir=/var/rancid \
        && make \
        && make install \
        && popd \
        && rm -rf rancid-${RANCID_VERSION} rancid-${RANCID_VERSION}.tar.gz \
        && groupadd -g 1000 rancid \
        && useradd -m -u 1000 -g 1000 -s /bin/bash -d /var/rancid -c RANCID rancid \
        && chown -R rancid:rancid /var/rancid

# install operating system configuration
COPY docker/ /
