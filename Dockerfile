###############################################
# Ubuntu with added Teamspeak 3 Server.
# Uses SQLite Database on default.
###############################################

# Using latest Ubuntu image as base
FROM ubuntu:16.04

MAINTAINER Alex

RUN apt-get update \
        && apt-get install -y wget bzip2 --no-install-recommends \
        && rm -r /var/lib/apt/lists/*

## Set some variables for override.
# Download Link of TS3 Server
ENV TEAMSPEAK_VERSION 3.0.13.3
ENV TEAMSPEAK_SHA256 e9f48c8a9bad75165e3a7c9d9f6b18639fd8aba63adaaa40aebd8114166273ae

# Inject a Volume for any TS3-Data that needs to be persisted or to be accessible from the host. (e.g. for Backups)
VOLUME ["/teamspeak3"]

# Download TS3 file and extract it into /opt.
RUN wget -O teamspeak3-server_linux-amd64.tar.bz2 http://dl.4players.de/ts/releases/${TEAMSPEAK_VERSION}/teamspeak3-server_linux_amd64-${TEAMSPEAK_VERSION}.tar.bz2 \
        && echo "${TEAMSPEAK_SHA256} *teamspeak3-server_linux-amd64.tar.bz2" | sha256sum -c - \
        && tar -C /opt -xjf teamspeak3-server_linux-amd64.tar.bz2 \
        && rm teamspeak3-server_linux-amd64.tar.bz2

ADD /scripts/ /opt/scripts/
RUN chmod -R 774 /opt/scripts/

ENTRYPOINT ["/opt/scripts/docker-ts3.sh"]
#CMD ["-w", "/teamspeak3/query_ip_whitelist.txt", "-b", "/teamspeak3/query_ip_blacklist.txt", "-o", "/teamspeak3/logs/", "-l", "/teamspeak3/"]

# Expose the Standard TS3 port.
EXPOSE 9987/udp
# for files
EXPOSE 30033
# for ServerQuery
EXPOSE 10011
