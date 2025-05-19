#!/bin/bash

# Tableau global pour stocker les sites à bloquer
websites_array=()

# Lit les noms de domaine depuis le fichier sites.txt
function query_websites() {
    local sites_file="sites.txt"
    
    if [[ ! -f "$sites_file" ]]; then
        echo "Erreur : le fichier '$sites_file' est introuvable." >&2
        return 1
    fi

    websites_array=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && websites_array+=("$line")
    done < "$sites_file"
}

# Vérifie si la section #flow-mode existe déjà dans /etc/hosts
function flow_mode_exists() {
    grep -Fxq "#flow-mode" /etc/hosts
}

# Ajoute une entrée 127.0.0.1 <domaine> juste après #flow-mode dans /etc/hosts
function add_host_under_flow_mode() {
    local domain="$1"
    local ip="127.0.0.1"
    local entry="$ip $domain"

    # Ne rien faire si l'entrée existe déjà
    if grep -Fxq "$entry" /etc/hosts; then
        echo "Déjà présent : $entry"
        return
    fi

    # Ajouter la section si elle n'existe pas
    if ! flow_mode_exists; then
        echo -e "\n#flow-mode" >> /etc/hosts
    fi

    # Ajoute l'entrée juste après #flow-mode
    awk -v new_entry="$entry" '
        BEGIN { added=0 }
        {
            print
            if ($0 == "#flow-mode" && !added) {
                print new_entry
                added=1
            }
        }
    ' /etc/hosts > /tmp/hosts.tmp && mv /tmp/hosts.tmp /etc/hosts

    echo "Ajouté sous #flow-mode : $entry"
}

# ---------- MAIN ----------

# Charge les sites à bloquer
query_websites

# Ajoute chaque site dans /etc/hosts
for site in "${websites_array[@]}"; do
    add_host_under_flow_mode "$site"
done
