#!/usr/bin/env bash

set -euo pipefail
# shellcheck source=scripts/functions.sh
source "/home/steam/server/functions.sh"

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

log_action "Preparing runtime user and files"
usermod -o -u "$PUID" steam
groupmod -o -g "$PGID" steam
mkdir -p /home/steam/server-files
chown -R steam:steam /home/steam

if [[ "${UPDATE_ON_START:-true}" == "true" ]]; then
    install_server
else
    log_warn "UPDATE_ON_START=false, skipping server update"
fi

exec su -p -s /bin/bash steam -c "/home/steam/server/start.sh"
