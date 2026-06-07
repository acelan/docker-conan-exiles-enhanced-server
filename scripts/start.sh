#!/usr/bin/env bash

set -euo pipefail
# shellcheck source=scripts/functions.sh
source "/home/steam/server/functions.sh"

SERVER_FILES="/home/steam/server-files"
CONFIG_DIR="${SERVER_FILES}/ConanSandbox/Saved/Config/LinuxServer"

PORT="${PORT:-7777}"
QUERY_PORT="${QUERY_PORT:-27015}"
RCON_PORT="${RCON_PORT:-25575}"
MAX_PLAYERS="${MAX_PLAYERS:-40}"
SERVER_NAME="${SERVER_NAME:-Conan Exiles Enhanced Server}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"
RCON_PASSWORD="${RCON_PASSWORD:-}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
MODS="${MODS:-}"
CONANEXILES_CMD_SWITCHES="${CONANEXILES_CMD_SWITCHES:-}"

mkdir -p "$CONFIG_DIR"

set_ini_value "${CONFIG_DIR}/Game.ini" "RconPlugin" "RconEnabled" "1"
set_ini_value "${CONFIG_DIR}/Game.ini" "RconPlugin" "RconPassword" "$RCON_PASSWORD"
set_ini_value "${CONFIG_DIR}/Game.ini" "RconPlugin" "RconPort" "$RCON_PORT"

if [[ -n "$ADMIN_PASSWORD" ]]; then
    set_ini_value "${CONFIG_DIR}/ServerSettings.ini" "ServerSettings" "AdminPassword" "$ADMIN_PASSWORD"
fi

apply_ini_overrides "$CONFIG_DIR"

if [[ -n "$MODS" ]]; then
    log_action "Installing mods"
    MODS_DIR="${SERVER_FILES}/ConanSandbox/Mods"
    mkdir -p "$MODS_DIR"
    : > "${MODS_DIR}/modlist.txt"

    IFS=',' read -r -a mod_ids <<< "$MODS"
    for mod_id in "${mod_ids[@]}"; do
        mod_id="${mod_id// /}"
        if [[ -z "$mod_id" ]]; then
            continue
        fi

        log_info "Downloading mod ${mod_id}"
        /depotdownloader/DepotDownloader -app 440900 -pubfile "$mod_id" -dir "${MODS_DIR}/${mod_id}" -validate >/dev/null 2>&1
        while IFS= read -r pak_file; do
            echo "*${mod_id}\\$(basename "$pak_file")" >> "${MODS_DIR}/modlist.txt"
        done < <(find "${MODS_DIR}/${mod_id}" -name '*.pak')
    done
fi

EXEC="${SERVER_FILES}/ConanSandboxServer.sh"
if [[ ! -f "$EXEC" ]]; then
    log_error "Could not find server executable at: $EXEC"
    exit 1
fi

chmod +x "$EXEC"
cd "$SERVER_FILES"

args=(
    /Game/Maps/ConanSandbox/ConanSandbox
    "-port=${PORT}"
    "-queryport=${QUERY_PORT}"
    "-MaxPlayers=${MAX_PLAYERS}"
    "-ServerName=${SERVER_NAME}"
    -server
    -log
)

if [[ -n "$SERVER_PASSWORD" ]]; then
    args+=("-ServerPassword=${SERVER_PASSWORD}")
fi

if [[ -n "$CONANEXILES_CMD_SWITCHES" ]]; then
    # shellcheck disable=SC2206
    extra_args=( $CONANEXILES_CMD_SWITCHES )
    args+=("${extra_args[@]}")
fi

log_info "Starting server on game port ${PORT}, query port ${QUERY_PORT}, rcon port ${RCON_PORT}"
exec "$EXEC" "${args[@]}"
