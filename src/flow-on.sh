#!/bin/bash

# Configuration des couleurs whiptail
export NEWT_COLORS='
    window=white,blue
    border=black,blue
    title=yellow,blue
    textbox=white,black
    checkbox=black,lightgray
    actcheckbox=white,red
'

# Envoie le script pour bloquer les sites
function sites_block(){
    if (whiptail --title "Flow-mode" --yesno "Do you want to block some website" 8 78); then        
        sudo ./sites-block.sh
    else
        echo "User selected No, website won't be blocked."
    fi
}

sites_block