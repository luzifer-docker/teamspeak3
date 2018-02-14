#!/bin/bash
set -euo pipefail

VOLUME=/teamspeak3

if [ -e "${VOLUME}/.ts3server_license_accepted" ]; then
  echo "- Accepting license as you requested"
  touch /opt/teamspeak3-server_linux_amd64/.ts3server_license_accepted
fi

echo "- Linking host mounted database..."

ln -s $VOLUME/ts3server.sqlitedb /opt/teamspeak3-server_linux_amd64/ts3server.sqlitedb

echo "- Link the files-folder into the host-mounted volume..."

mkdir -p ${VOLUME}/files
if ! [ -L /opt/teamspeak3-server_linux_amd64/files ]; then
  rm -rf /opt/teamspeak3-server_linux_amd64/files
  ln -s ${VOLUME}/files /opt/teamspeak3-server_linux_amd64/files
fi

echo "- Starting TS3-Server..."
if [ -f "${VOLUME}/ts3server.ini" ]; then
  echo "  '${VOLUME}/ts3server.ini' found. Using as config file."
  echo "  HINT: If this ini was transfered from another ts3-install you may want"
  echo "  to make sure the following settings are active for the usage of host-mounted volume:"
  echo "  - query_ip_whitelist='${VOLUME}/query_ip_whitelist.txt'"
  echo "  - query_ip_backlist='${VOLUME}/query_ip_blacklist.txt'"
  echo "  - logpath='${VOLUME}/logs/'"
  echo "  - licensepath='${VOLUME}/'"
  echo "  - inifile='${VOLUME}/ts3server.ini'"
  /opt/teamspeak3-server_linux_amd64/ts3server_minimal_runscript.sh \
    inifile="${VOLUME}/ts3server.ini"
else
  echo "  '${VOLUME}/ts3server.ini' not found. Creating new config file."
  /opt/teamspeak3-server_linux_amd64/ts3server_minimal_runscript.sh \
    createinifile=1 \
    inifile="${VOLUME}/ts3server.ini" \
    licensepath="${VOLUME}/" \
    logpath="${VOLUME}/logs/" \
    query_ip_backlist="${VOLUME}/query_ip_blacklist.txt" \
    query_ip_whitelist="${VOLUME}/query_ip_whitelist.txt"
fi
