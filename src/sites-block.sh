#!/bin/bash

# Configuration des couleurs whiptail
export NEWT_COLORS='
    root=green,black
    border=green,black
    title=green,black
    roottext=white,black
    window=green,black
    textbox=white,black
    button=black,green
    compactbutton=white,black
    listbox=white,black
    actlistbox=black,white
    actsellistbox=black,green
    checkbox=green,black
    actcheckbox=black,green
'

CONFIG_FILE="blocked_sites.conf"
TEMPFILE=$(mktemp)

# Listes des sites whiptail
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

# Variables globales
declare -A selected_map
declare -a options
declare -a websites_array

# Vérifie la présence d'un fichier de config existante
function load_existing_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        while read -r domain; do
            [[ -n "$domain" ]] && selected_map["$domain"]=1
        done < "$CONFIG_FILE"
    fi
}


# Creer la page whiptail pour selectionner les options
function build_whiptail_options() {
    options=()
    for label in "${!sites[@]}"; do
        domain="${sites[$label]}"
        if [[ ${selected_map[$domain]} ]]; then
            options+=("$label" "" ON)
        else
            options+=("$label" "" OFF)
        fi
    done
}


# Affiche whiptail 
function get_user_selection() {
    whiptail --title "Blocage de Sites Web" \
             --checklist "Sélectionne les sites à bloquer :" \
             20 70 12 \
             "${options[@]}" 2> "$TEMPFILE"

    if [[ $? -ne 0 ]]; then
        echo "Opération annulée."
        rm -f "$TEMPFILE"
        exit 1
    fi
}

# Panel whiptail qui permets d'ajouter manuellement des sites
function build_whiptail_manual(){
# Option d'ajout manuel
if whiptail --yesno "Do you want to block manually other(s) website(s) ?" 10 60; then
    manual_input=$(whiptail --inputbox "Enter domain name (ie : www.snapchat.com / snapchat.com.         Warning : separate with a space for multiple domains !:" 10 70 3>&1 1>&2 2>&3)
    
    for domain in $manual_input; do
        # Ajoute à la map de sélection
        selected_map["$domain"]=1
        # Ajoute à la map des sites si besoin (optionnel si tu veux que ça apparaisse dans le futur)
        sites["$domain"]="$domain"
    done
fi
}

# Enregistre sous forme d'un .txt le fichier de configuration pour les prochains lancements
function save_config() {
    selection=$(<"$TEMPFILE")
    rm -f "$TEMPFILE"
    selection=$(echo "$selection" | tr -d '"')

    > "$CONFIG_FILE"
    for label in $selection; do
        echo "${sites[$label]}" >> "$CONFIG_FILE"
    done

    # Ajouter les domaines manuels (déjà dans selected_map mais pas dans selection)
    for domain in "${!selected_map[@]}"; do
        found=0
        for label in $selection; do
            [[ "${sites[$label]}" == "$domain" ]] && found=1
        done
        [[ $found -eq 0 ]] && echo "$domain" >> "$CONFIG_FILE"
    done

    echo "Configuration sauvegardée dans $CONFIG_FILE."
}

# Vérifie si la partie flow-mode existe dans le fichier hosts
function flow_mode_exists() {
    grep -Fxq "#flow-mode" /etc/hosts
}

# Ajoute une entrée qui pointe vers localhost dans le fichier hosts
function add_host_under_flow_mode() {
    local domain="$1"
    local entry="127.0.0.1 $domain"

    if grep -Fxq "$entry" /etc/hosts; then
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

# Main

# Si le fichier n'existe pas, le créer vide
[[ ! -f "$CONFIG_FILE" ]] && touch "$CONFIG_FILE"

# Étapes du programme
load_existing_config
build_whiptail_options
get_user_selection
build_whiptail_manual
save_config

# Ajouter les entrées dans /etc/hosts
for domain in $(<"$CONFIG_FILE"); do
    add_host_under_flow_mode "$domain"
done

echo "Sites bloqués avec succès."