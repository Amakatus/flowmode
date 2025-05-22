#!/bin/bash

send_notification() {
    local title="$1"
    local message="$2"

    # Détection de notify-send (libnotify, GNOME, KDE, XFCE, etc.)
    if command -v notify-send >/dev/null 2>&1; then
        echo 1
        notify-send "$title" "$message"
        exit 0
    fi

    # Détection de kdialog (KDE)
    if command -v kdialog >/dev/null 2>&1; then
        kdialog --passivepopup "$message" 5 --title "$title"
        exit 0
    fi

    # Détection de zenity (fallback)
    if command -v zenity >/dev/null 2>&1; then
        zenity --notification --window-icon="info" --text="$title: $message"
        exit 0
    fi

    # Détection de wall (terminal)
    if command -v wall >/dev/null 2>&1; then
        echo "$title: $message" | wall
        exit 0
    fi

    echo "Aucun système de notification graphique trouvé."
    exit 1
}

send_notification "Flow-Mode disable" "Notifications are back !"