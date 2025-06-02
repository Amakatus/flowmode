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

function sites_block(){
    if (whiptail --title "Flow-mode" --yesno "Do you want to block some website?" 8 78); then        
        sudo ./sites-block.sh
    else
        echo "User selected No, website won't be blocked."
    fi
}

function sites_notification(){
    if (whiptail --title "Flow-mode" --yesno "Do you want to turn off notifications?" 8 78); then        
        bash disable-notification.sh
    else
        echo "User selected No, notifications won't be blocked."
    fi
}

# Menu Rofi
CHOICE=$(printf "Bloquer sites\nDésactiver notifications" | rofi -dmenu -p "Flow-mode")

case "$CHOICE" in
    "Bloquer sites")
        sites_block
        ;;
    "Désactiver notifications")
        sites_notification
        ;;
    *)
        echo "Action annulée."
        ;;
esac
