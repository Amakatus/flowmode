#!/bin/bash

# Config whiptail

export NEWT_COLORS='
    window=white,blue
    border=black,blue
    title=yellow,blue
    textbox=white,black
    checkbox=black,lightgray
    actcheckbox=white,red
'


# Liste de sites populaires à proposer
declare -A sites=(
    ["Facebook"]="www.facebook.com"
    ["Instagram"]="www.instagram.com"
    ["TikTok"]="www.tiktok.com"
    ["Twitter (X)"]="twitter.com"
    ["YouTube"]="www.youtube.com"
    ["Reddit"]="www.reddit.com"
    ["Netflix"]="www.netflix.com"
    ["Snapchat"]="www.snapchat.com"
    ["OpenAI"]="openai.com"
    ["ChatGPT"]="www.chatgpt.com"
)

# Fichier temporaire pour sélection
TEMPFILE=$(mktemp)

# Construire la liste des options pour Whiptail
options=()
for name in "${!sites[@]}"; do
    options+=("$name" "" OFF)
done

# Affiche la boîte de sélection
whiptail --title "Sélection des sites à bloquer" \
         --checklist "Choisissez les sites à bloquer :" \
         20 78 12 \
         "${options[@]}" 2> "$TEMPFILE"

# Si l'utilisateur annule
if [ $? -ne 0 ]; then
    echo "Opération annulée."
    rm -f "$TEMPFILE"
    exit 1
fi

# Récupérer la sélection
selection=$(<"$TEMPFILE")
rm -f "$TEMPFILE"

# Nettoyer les guillemets et extraire les domaines sélectionnés
selected_domains=()
for name in $selection; do
    clean_name=$(echo "$name" | tr -d '"')
    selected_domains+=("${sites[$clean_name]}")
done

# Vérifie si #flow-mode est présent
function flow_mode_exists() {
    grep -Fxq "#flow-mode" /etc/hosts
}

# Ajoute une entrée sous #flow-mode
function add_host_under_flow_mode() {
    local domain="$1"
    local entry="127.0.0.1 $domain"

    if grep -Fq "$domain" /etc/hosts; then
        echo "Déjà présent : $entry"
        return
    fi

    if ! flow_mode_exists; then
        echo -e "\n#flow-mode" >> /etc/hosts
    fi

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

# Appliquer les blocs
for domain in "${selected_domains[@]}"; do
    add_host_under_flow_mode "$domain"
done
