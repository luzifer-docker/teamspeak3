#!/bin/bash
set -euo pipefail

ver=$(grep -Eo 'TEAMSPEAK_VERSION=([0-9.]+)' Dockerfile | cut -d '=' -f 2)

[ -n "${ver}" ] || {
	echo "No version found"
	exit 1
}

git commit -m "Teamspeak Server ${ver}" Dockerfile
git tag "${ver}"
