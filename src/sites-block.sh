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

CONFIG_FILE="blocked_sites.txt"
TEMPFILE=$(mktemp)

# Listes des sites whiptail par défaut
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

declare -A selected_map  # Domaines sélectionnés
declare -A custom_sites  # Domaines customs
declare -a options

# Charge la config existante
function load_existing_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        while read -r domain; do
            [[ -n "$domain" ]] && selected_map["$domain"]=1
        done < "$CONFIG_FILE"
    fi
}

# Charge les customs (tous ceux non dans la liste par défaut)
function load_custom_sites() {
    if [[ -f "$CONFIG_FILE" ]]; then
        for domain in $(cat "$CONFIG_FILE"); do
            found=0
            for d in "${sites[@]}"; do
                [[ "$domain" == "$d" ]] && found=1 && break
            done
            [[ $found -eq 0 ]] && custom_sites["$domain"]="$domain"
        done
    fi
}

# Concatène les deux listes pour whiptail
function build_whiptail_options() {
    options=()
    for label in "${!sites[@]}"; do
        domain="${sites[$label]}"
        if [[ ${selected_map[$domain]} ]]; then
            options+=("$label" "$domain" ON)
        else
            options+=("$label" "$domain" OFF)
        fi
    done
    # Ajoute les customs
    for domain in "${!custom_sites[@]}"; do
        if [[ ${selected_map[$domain]} ]]; then
            options+=("$domain" "$domain" ON)
        else
            options+=("$domain" "$domain" OFF)
        fi
    done
}

# Affiche la sélection
function get_user_selection() {
    whiptail --title "Blocage de Sites Web" \
             --checklist "Sélectionne les sites à bloquer.\n(Désélectionne un domaine custom pour le supprimer)" \
             20 70 14 \
             "${options[@]}" 2> "$TEMPFILE"

    if [[ $? -ne 0 ]]; then
        echo "Opération annulée."
        rm -f "$TEMPFILE"
        exit 1
    fi

    # Réinitialiser la map de sélection
    for d in "${sites[@]}"; do selected_map["$d"]=0; done
    for d in "${!custom_sites[@]}"; do selected_map["$d"]=0; done

    # Met à jour la map avec la sélection
    for selected in $(tr -d '"' < "$TEMPFILE"); do
        # Associe nom du label/domaine à la valeur
        if [[ ${sites[$selected]+_} ]]; then
            selected_map["${sites[$selected]}"]=1
        elif [[ ${custom_sites[$selected]+_} ]]; then
            selected_map["$selected"]=1
        else
            # Peut arriver si on coche un custom domaine dont le label = le domaine
            selected_map["$selected"]=1
        fi
    done
}

# Ajout manuel de domaines customs
function build_whiptail_manual(){
    if whiptail --yesno "Veux-tu ajouter un autre site personnalisé à bloquer ?" 10 60; then
        manual_input=$(whiptail --inputbox "Entre un ou plusieurs domaines séparés par un espace (ex: www.site1.com site2.com):" 10 70 3>&1 1>&2 2>&3)
        for domain in $manual_input; do
            [[ -n "$domain" ]] || continue
            selected_map["$domain"]=1
            custom_sites["$domain"]="$domain"
        done
    fi
}

# Sauvegarde la config sélectionnée
function save_config() {
    > "$CONFIG_FILE"
    # Sites par défaut
    for label in "${!sites[@]}"; do
        domain="${sites[$label]}"
        if [[ ${selected_map[$domain]} -eq 1 ]]; then
            echo "$domain" >> "$CONFIG_FILE"
        fi
    done
    # Customs sélectionnés uniquement
    for domain in "${!custom_sites[@]}"; do
        if [[ ${selected_map[$domain]} -eq 1 ]]; then
            echo "$domain" >> "$CONFIG_FILE"
        fi
    done
    echo "Configuration sauvegardée dans $CONFIG_FILE."
}

# Nettoie la section #flow-mode dans /etc/hosts
function clean_flow_mode_hosts() {
    if grep -q "#flow-mode" /etc/hosts; then
        # Supprime tout ce qui suit (et y compris) #flow-mode
        sudo awk '/#flow-mode/ {print; exit} {print}' /etc/hosts > /tmp/hosts.tmp
        sudo mv /tmp/hosts.tmp /etc/hosts
    fi
}

# Ajoute les domaines sélectionnés dans /etc/hosts sous #flow-mode
function add_hosts_entries() {
    sudo bash -c "echo '#flow-mode' >> /etc/hosts"
    while read -r domain; do
        [[ -n "$domain" ]] && sudo bash -c "echo '127.0.0.1 $domain' >> /etc/hosts"
    done < "$CONFIG_FILE"
}

# Retire les customs désélectionnés
function purge_unselected_customs() {
    for domain in "${!custom_sites[@]}"; do
        if [[ ${selected_map[$domain]} -ne 1 ]]; then
            unset custom_sites["$domain"]
        fi
    done
}

# Main
[[ ! -f "$CONFIG_FILE" ]] && touch "$CONFIG_FILE"

load_existing_config
load_custom_sites
build_whiptail_options
get_user_selection
build_whiptail_manual
purge_unselected_customs
save_config
clean_flow_mode_hosts
add_hosts_entries

echo "Sites bloqués avec succès."
