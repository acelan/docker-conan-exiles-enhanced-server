#!/usr/bin/env bash

set -euo pipefail

LINE='\n'
RESET='\033[0m'
WHITE='\033[0;37m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'

log() {
    local message="$1"
    local color="$2"
    local prefix="${3:-}"
    local suffix="${4:-}"
    printf "$color%s$RESET$LINE" "${prefix}${message}${suffix}"
}

log_info() { log "$1" "$WHITE"; }
log_warn() { log "$1" "$YELLOW"; }
log_error() { log "$1" "$RED"; }
log_success() { log "$1" "$GREEN"; }
log_action() { log "$1" "$CYAN" "==== " " ===="; }

set_ini_value() {
    local file="$1"
    local section="$2"
    local key="$3"
    local value="$4"

    mkdir -p "$(dirname "$file")"
    touch "$file"
    crudini --set "$file" "$section" "$key" "$value"
}

normalize_ini_filename() {
    local name="$1"
    if [[ ! "$name" =~ ^[A-Za-z0-9]+(\.ini)?$ ]]; then
        return 1
    fi

    if [[ "$name" == *.ini ]]; then
        printf '%s\n' "$name"
        return 0
    fi

    printf '%s.ini\n' "$name"
}

apply_ini_overrides() {
    local config_dir="$1"
    local applied_count=0

    while IFS='=' read -r env_name env_value; do
        local file_name=""
        local section=""
        local key=""

        if [[ "$env_name" =~ ^CONANEXILES_INI_([^_]+)__([^_].*)__([^_].*)$ ]]; then
            file_name="${BASH_REMATCH[1]}"
            section="${BASH_REMATCH[2]}"
            key="${BASH_REMATCH[3]}"
        elif [[ "$env_name" =~ ^CONANEXILES_([A-Za-z0-9]+)_([A-Za-z0-9]+)_([A-Za-z0-9]+)$ ]]; then
            file_name="${BASH_REMATCH[1]}"
            section="${BASH_REMATCH[2]}"
            key="${BASH_REMATCH[3]}"
        else
            continue
        fi

        local ini_file
        if ! ini_file="$(normalize_ini_filename "$file_name")"; then
            log_warn "Skipping invalid ini filename from ${env_name}"
            continue
        fi

        set_ini_value "${config_dir}/${ini_file}" "$section" "$key" "$env_value"
        applied_count=$((applied_count + 1))
    done < <(env)

    if [[ "$applied_count" -gt 0 ]]; then
        log_success "Applied ${applied_count} INI override(s) from environment"
    fi
}

install_server() {
    log_action "Installing Conan Exiles Enhanced Dedicated Server"

    /depotdownloader/DepotDownloader \
        -app 443030 \
        -dir /home/steam/server-files \
        -validate

    log_success "Server install/update complete"
}
