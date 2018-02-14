FROM debian

LABEL maintainer Knut Ahlers <knut@ahlers.me>

ENV TEAMSPEAK_VERSION=3.1.0 \
    TEAMSPEAK_SHA256=9f18cff600b9ce82a26ab788633cd5004bbe8c86963507efd3704c085f50a391

RUN set -ex \
 && apt-get update \
 && apt-get install -y curl bzip2 ca-certificates --no-install-recommends \
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
