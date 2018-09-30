FROM debian:jessie-slim

MAINTAINER Simon Hookway <simon@obsidian.com.au>

ENV DEBIAN_FRONTEND noninteractive

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG TIMEZONE
ARG CLIENT
ARG MODULE
ARG VERSION
ARG DF_PORTS

ENV http_proxy ${HTTP_PROXY:-}
ENV https_proxy ${HTTPS_PROXY:-}

COPY conf/jessie.sources.list /etc/apt/sources.list
COPY skel/root/ /root/

# For some reason this directory does not exist and the next run breaks
RUN mkdir /var/cache/apt/archives

# Install base libraries and fix locale
RUN apt-get clean \
  && apt-get update \
  && apt-get install --yes apt-utils vim less vim htop wget unzip curl locales net-tools screen tcpdump strace \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && ln -s /etc/locale.alias /usr/share/locale/locale.alias \
  && /usr/sbin/locale-gen en_US.UTF-8 \
  && dpkg-reconfigure -f noninteractive locales \
  && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Fix timezone
RUN rm /etc/localtime \
  && ln -sv /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata

# Add the proxy to /etc/bash.bashrc
RUN echo "\n\nexport http_proxy=$HTTP_PROXY\nexport https_proxy=$HTTPS_PROXY" >> /etc/bash.bashrc

# Install some things.
RUN apt-get install --yes --no-install-recommends apt-transport-https ca-certificates \
  gnupg2 software-properties-common mysql-client-5.5 patch python python-setuptools \
  python-dev supervisor sudo \
  && mkdir -p /var/log/supervisor \
  && mkdir -p /etc/supervisor/conf.d

COPY conf/supervisor.conf.d/ /etc/supervisor/conf.d/
COPY conf/supervisord.conf /etc/

# Install ZMQ
RUN apt-get update && apt-get install --yes --no-install-recommends \
    libtool pkg-config build-essential autoconf automake uuid-dev \
  && cd /usr/src \
  && wget https://github.com/zeromq/libzmq/releases/download/v4.2.1/zeromq-4.2.1.tar.gz \
  && tar -zxf zeromq-4.2.1.tar.gz \
  && cd zeromq-4.2.1/ \
  && ./configure \
  && make install \
  && ldconfig \
  && cd .. \
  && rm -rf zeromq-4.2.1 \
  && apt-get remove --yes build-essential gcc make \
  && apt-get autoremove --yes \
  && easy_install pip \
  && pip install 'pyzmq<16'

# Install the Jet Components
COPY eggs/ /usr/src/eggs/
RUN apt-get install --yes --no-install-recommends libtool pkg-config build-essential autoconf \
    automake libxml2-dev libxslt1-dev zlib1g-dev lib32z1-dev libmysqlclient-dev libyaml-dev \
    python-imaging python-libxml2 python-libxslt1 python-pysqlite2 \
  && pip install /usr/src/eggs/elementtree-1.2.7-20070827-preview.zip \
  && pip install /usr/src/eggs/python-openid-1.2.0.zip \
  && pip install /usr/src/eggs/python-urljr-1.0.1.tar.gz \
  && pip install /usr/src/eggs/python-yadis-1.1.0.tar.gz \
  && pip install /usr/src/eggs/argh-0.26.2.tar.gz \
  && pip install /usr/src/eggs/bzr-2.6b1.tar.gz \
  && pip install /usr/src/eggs/cdecimal-2.3.tar.gz \
  && pip install /usr/src/eggs/ClientCookie-1.3.0.zip \
  && pip install /usr/src/eggs/decorator-3.3.2.tar.gz \
  && pip install /usr/src/eggs/egenix-mx-base-3.2.3.tar.gz \
  && pip install /usr/src/eggs/lxml-2.3.2.tar.gz \
  && pip install /usr/src/eggs/MySQL-python-1.2.3.tar.gz \
  && pip install /usr/src/eggs/pycrypto-2.5.tar.gz \
  && pip install /usr/src/eggs/paramiko-1.7.7.1.zip \
  && pip install /usr/src/eggs/pathtools-0.1.2.tar.gz \
  && pip install /usr/src/eggs/pydns-2.3.6.tar.gz \
  && pip install /usr/src/eggs/pyPdf-1.13.zip \
  && pip install /usr/src/eggs/python-cjson-1.0.5.tar.gz \
  && pip install /usr/src/eggs/python-suds-0.4.tar.gz \
  && pip install /usr/src/eggs/pyTools-0.5.32.tar.gz \
  && pip install /usr/src/eggs/PyYAML-3.12.tar.gz \
  && pip install /usr/src/eggs/simplejson-2.0.5.tar.gz \
  && pip install /usr/src/eggs/SimpleTAL-4.1.tar.gz \
  && pip install /usr/src/eggs/Beaker-1.6.3.tar.gz \
  && pip install /usr/src/eggs/BeautifulSoup-3.2.1.tar.gz \
  && pip install /usr/src/eggs/FormEncode-1.2.4.tar.gz \
  && pip install /usr/src/eggs/Genshi-0.4.4.zip \
  && pip install /usr/src/eggs/MarkupSafe-0.15.tar.gz \
  && pip install /usr/src/eggs/Mako-0.7.0.tar.gz \
  && pip install /usr/src/eggs/nose-1.1.2.tar.gz \
  && pip install /usr/src/eggs/Paste-1.7.5.1.tar.gz \
  && pip install /usr/src/eggs/PasteDeploy-1.3.3.tar.gz \
  && pip install /usr/src/eggs/PasteScript-1.7.3.tar.gz \
  && pip install /usr/src/eggs/Pygments-1.5.tar.gz \
  && pip install /usr/src/eggs/Routes-1.10.1.tar.gz \
  && pip install /usr/src/eggs/Tempita-0.5.1.tar.gz \
  && pip install /usr/src/eggs/WebError-0.10.3.tar.gz \
  && pip install /usr/src/eggs/WebHelpers-0.6.3.tar.gz \
  && pip install /usr/src/eggs/WebOb-0.9.7.1.tar.gz \
  && pip install /usr/src/eggs/WebTest-1.1.tar.gz \
  && pip install /usr/src/eggs/wsgiref-0.1.2.zip \
  && pip install /usr/src/eggs/Pylons-0.9.7rc2.tar.gz \
  && pip install requests requests_toolbelt requests-oauthlib netaddr unittest2 watchdog \
  && pip install /usr/src/eggs/Jet-3.0.0-rc24.tar.gz \
  && apt-get remove --yes build-essential gcc make \
  && apt-get autoremove --yes
 
# Copy the Supervisor files here so they can be changed without rebuilding the above
COPY conf/supervisor.conf.d/ /etc/supervisor/conf.d/
COPY conf/supervisord.conf /etc/supervisor/
COPY conf/supervisor.defaults.conf /tmp/
RUN cat /tmp/supervisor.defaults.conf >> /etc/default/supervisor && rm /tmp/supervisor.defaults.conf

# Setup the jet homedir
ENV JETHOME /home/jet
RUN useradd --create-home --home-dir $JETHOME --shell /bin/bash --uid 1001 jet 
COPY skel/jet/ $JETHOME/
COPY conf/docker/defaults $JETHOME/cfg/
RUN echo "export MODULE=${MODULE}" > $JETHOME/cfg/build-args \
  && echo "export CLIENT=${CLIENT}" >> $JETHOME/cfg/build-args \
  && echo "export VERSION=${VERSION}" >> $JETHOME/cfg/build-args \
  && chown -R jet:jet $JETHOME \
  && chmod 755 $JETHOME/bin/*
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

STOPSIGNAL SIGTERM

VOLUME ["/opt/Usage", "/opt/Archive", "/opt/Reports", "/opt/ramdisk"]
EXPOSE $DF_PORTS

CMD ["start"]
