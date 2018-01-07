FROM debian

LABEL maintainer Knut Ahlers <knut@ahlers.me>

ENV TEAMSPEAK_VERSION=3.0.13.8 \
    TEAMSPEAK_SHA256=460c771bf58c9a49b4be2c677652f21896b98a021d7fff286e59679b3f987a59

RUN set -ex \
 && apt-get update \
 && apt-get install -y curl bzip2 --no-install-recommends \
 && curl -sSfLo teamspeak3-server_linux-amd64.tar.bz2 \
      http://dl.4players.de/ts/releases/${TEAMSPEAK_VERSION}/teamspeak3-server_linux_amd64-${TEAMSPEAK_VERSION}.tar.bz2 \
 && echo "${TEAMSPEAK_SHA256} *teamspeak3-server_linux-amd64.tar.bz2" | sha256sum -c - \
 && tar -C /opt -xjf teamspeak3-server_linux-amd64.tar.bz2 \
 && rm teamspeak3-server_linux-amd64.tar.bz2 \
 && apt-get purge -y curl bzip2 && apt-get autoremove -y \
 && rm -r /var/lib/apt/lists/*

ADD docker-ts3.sh /opt/docker-ts3.sh

# Inject a Volume for any TS3-Data that needs to be persisted or to be accessible from the host. (e.g. for Backups)
VOLUME ["/teamspeak3"]

CMD ["/opt/docker-ts3.sh"]

# Expose the Standard TS3 port, for files, for serverquery
EXPOSE 9987/udp 30033 10011
