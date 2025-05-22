#!/bin/bash

set -e

HOSTS_FILE="/etc/hosts"

if [ ! -f "$HOSTS_FILE" ]; then
    echo "Hosts file '$HOSTS_FILE' not found."
    exit 1
fi

# Check if flow-mode is already disabled
function check_flow_mode_disabled {
    if ! grep -q "#flow-mode" "$HOSTS_FILE"; then
        echo "Flow-mode is already disabled."
        exit 0
    fi
}

function disable_flow_mode {
    sudo awk '/^#flow-mode/ {skip=1; next} /^#/ { if (skip) {skip=0; print; next}} !skip {print}' \
        "$HOSTS_FILE" > temp_hosts \
        && sudo mv temp_hosts "$HOSTS_FILE"
    echo "Flow-mode has been disabled."
}


check_flow_mode_disabled
disable_flow_mode
