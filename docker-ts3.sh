#!/bin/bash
set -euo pipefail

function log() {
  echo "[$(date +%H:%M:%S)] $@" >&2
}

VOLUME=/teamspeak3

if [ -e "${VOLUME}/.ts3server_license_accepted" ]; then
  log "- Accepting license as you requested"
  touch /opt/teamspeak3-server_linux_amd64/.ts3server_license_accepted
fi

if ! [ -L /opt/teamspeak3-server_linux_amd64/ts3server.sqlitedb ]; then
  log "- Linking host mounted database..."
  ln -s ${VOLUME}/ts3server.sqlitedb /opt/teamspeak3-server_linux_amd64/ts3server.sqlitedb
fi

mkdir -p ${VOLUME}/files
if ! [ -L /opt/teamspeak3-server_linux_amd64/files ]; then
  log "- Link the files-folder into the host-mounted volume..."
  rm -rf /opt/teamspeak3-server_linux_amd64/files
  ln -s ${VOLUME}/files /opt/teamspeak3-server_linux_amd64/files
fi

log "- Starting TS3-Server..."
if [ -f "${VOLUME}/ts3server.ini" ]; then
  log "  '${VOLUME}/ts3server.ini' found. Using as config file."
  log "  HINT: If this ini was transfered from another ts3-install you may want"
  log "  to make sure the following settings are active for the usage of host-mounted volume:"
  log "  - query_ip_whitelist='${VOLUME}/query_ip_whitelist.txt'"
  log "  - logpath='${VOLUME}/logs/'"
  log "  - licensepath='${VOLUME}/'"
  log "  - inifile='${VOLUME}/ts3server.ini'"
  /opt/teamspeak3-server_linux_amd64/ts3server_minimal_runscript.sh \
    inifile="${VOLUME}/ts3server.ini"
else
  log "  '${VOLUME}/ts3server.ini' not found. Creating new config file."
  /opt/teamspeak3-server_linux_amd64/ts3server_minimal_runscript.sh \
    createinifile=1 \
    inifile="${VOLUME}/ts3server.ini" \
    licensepath="${VOLUME}/" \
    logpath="${VOLUME}/logs/" \
    query_ip_allowlist="${VOLUME}/query_ip_whitelist.txt"
fi
