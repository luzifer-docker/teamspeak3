FROM debian:bullseye

LABEL maintainer Knut Ahlers <knut@ahlers.me>

# Get the SHA256 from https://www.teamspeak.com/en/downloads#server
ENV TEAMSPEAK_VERSION=3.13.7 \
    TEAMSPEAK_SHA256=775a5731a9809801e4c8f9066cd9bc562a1b368553139c1249f2a0740d50041e

SHELL ["/bin/bash", "-o", "pipefail", "-exc"]

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
      bzip2 \
      ca-certificates \
      curl \
      dumb-init \
 && curl -sSfLo teamspeak3-server_linux-amd64.tar.bz2 \
      "https://files.teamspeak-services.com/releases/server/${TEAMSPEAK_VERSION}/teamspeak3-server_linux_amd64-${TEAMSPEAK_VERSION}.tar.bz2" \
 && echo "${TEAMSPEAK_SHA256} *teamspeak3-server_linux-amd64.tar.bz2" | sha256sum -c - \
 && tar -C /opt -xjf teamspeak3-server_linux-amd64.tar.bz2 \
 && rm teamspeak3-server_linux-amd64.tar.bz2 \
 && apt-get purge -y \
      bzip2 \
      curl \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd -g 1000 teamspeak \
 && useradd -u 1000 -g 1000 teamspeak \
 && chown -R teamspeak:teamspeak /opt/teamspeak3-server_linux_amd64

COPY docker-ts3.sh /opt/docker-ts3.sh

# Inject a Volume for any TS3-Data that needs to be persisted or to be accessible from the host. (e.g. for Backups)
VOLUME ["/teamspeak3"]

USER teamspeak
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/opt/docker-ts3.sh"]

# Expose the Standard TS3 port, for files, for serverquery
EXPOSE 9987/udp 30033 10011
