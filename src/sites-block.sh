#!/bin/bash

# === CONFIG COULEURS ===
export NEWT_COLORS='
    window=white,blue
    border=black,blue
    title=yellow,blue
    textbox=white,black
    checkbox=black,lightgray
    actcheckbox=white,red
'

# === FICHIERS DE CONFIGURATION ===
CONFIG_FILE="blocked_sites.conf"
TEMPFILE=$(mktemp)

# === LISTE DES SITES DISPONIBLES ===
declare -A sites=(
    ["Facebook"]="www.facebook.com"
    ["Instagram"]="www.instagram.com"
    ["TikTok"]="www.tiktok.com"
    ["YouTube"]="www.youtube.com"
    ["Reddit"]="www.reddit.com"
    ["Twitter (X)"]="twitter.com"
    ["Snapchat"]="www.snapchat.com"
    ["Netflix"]="www.netflix.com"
    ["OpenAI"]="openai.com"
    ["ChatGPT"]="www.chatgpt.com"
)

# === CHARGER CONFIG EXISTANTE ===
declare -A selected_map
if [[ -f "$CONFIG_FILE" ]]; then
    while read -r domain; do
        [[ -n "$domain" ]] && selected_map["$domain"]=1
    done < "$CONFIG_FILE"
fi

# === CONSTRUIRE LES OPTIONS WHIPTAIL AVEC PRÉ-SÉLECTION ===
options=()
for label in "${!sites[@]}"; do
    domain="${sites[$label]}"
    if [[ ${selected_map[$domain]} ]]; then
        options+=("$label" "" ON)
    else
        options+=("$label" "" OFF)
    fi
done

# === AFFICHER WHIPTAIL ===
whiptail --title "🛑 Blocage de Sites Web" \
         --checklist "Sélectionne les sites à bloquer :" \
         20 70 12 \
         "${options[@]}" 2> "$TEMPFILE"

if [ $? -ne 0 ]; then
    echo "Opération annulée."
    rm -f "$TEMPFILE"
    exit 1
fi

# === TRAITEMENT DE LA NOUVELLE CONFIGURATION ===
selection=$(<"$TEMPFILE")
rm -f "$TEMPFILE"

# Nettoyer les guillemets
selection=$(echo "$selection" | tr -d '"')

# Créer une nouvelle config propre
> "$CONFIG_FILE"
for label in $selection; do
    echo "${sites[$label]}" >> "$CONFIG_FILE"
done

echo "Configuration sauvegardée dans $CONFIG_FILE."
