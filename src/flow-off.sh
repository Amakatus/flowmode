#!/bin/bash

set -e

HOSTS_FILE="/etc/hosts"

if [ ! -f "$HOSTS_FILE" ]; then
    echo "Hosts file '$HOSTS_FILE' not found."
    exit 1
fi

# Fichier temporaire
TMP_FILE=$(mktemp)

# Remove all lines between "#flow-mode" and the next line starting with "#" or end of file
sed '/^# flow-mode/,/^#/{/^# flow-mode/p; /^#/{/^# flow-mode/!p;}; /^[^#]/d;}' "$HOSTS_FILE" > "$TMP_FILE"

# Remplacer le fichier hosts d'origine par le fichier temporaire
sudo mv "$TMP_FILE" "$HOSTS_FILE"

echo "Flow-mode disabled !"
