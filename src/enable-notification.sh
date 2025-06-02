#!/bin/bash

set -e

enable_notifications() {
    # GNOME
    if command -v gsettings &>/dev/null && \
        gsettings list-schemas | grep -q "org.gnome.desktop.notifications"; then
         gsettings set org.gnome.desktop.notifications show-banners true
    fi

    # KDE Plasma
    if command -v qdbus &>/dev/null; then
        qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.setEnabled true 2>/dev/null || true
    fi

    # XFCE
    if command -v xfconf-query &>/dev/null; then
        xfconf-query -c xfce4-notifyd -p /do-not-disturb -s false 2>/dev/null || true
    fi

    # MATE
    if command -v dconf &>/dev/null; then
        dconf write /org/mate/notification-daemon/enable true 2>/dev/null || true
    fi

    # Cinnamon
    if command -v gsettings &>/dev/null; then
        gsettings set org.cinnamon.desktop.notifications display-notifications true 2>/dev/null || true
    fi

    # LXQt
    if pgrep lxqt-notificationd &>/dev/null; then
        pkill -SIGUSR1 lxqt-notificationd 2>/dev/null || true
        if command -v lxqt-notificationd &>/dev/null; then
            lxqt-notificationd &>/dev/null &
        fi
    fi

    # libnotify (notify-osd)
    if ! pgrep notify-osd &>/dev/null && command -v notify-osd &>/dev/null; then
        notify-osd &>/dev/null &
    fi

    # Wayland (sway)
    if command -v swaymsg &>/dev/null; then
        swaymsg 'output * inhibit_idle off' 2>/dev/null || true
    fi

    # Wayland (mako)
    if pgrep mako &>/dev/null; then
        pkill -SIGUSR2 mako 2>/dev/null || true
    elif command -v mako &>/dev/null; then
        mako &>/dev/null &
    fi

    # Hyprland (swaync)
    if pgrep swaync &>/dev/null; then
        swaync-client -dn -t 2>/dev/null || true
    fi
}

send_notification() {
    local title="$1"
    local message="$2"

    # notify-send (libnotify, GNOME, KDE, XFCE, etc.)
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$message"
        return 0
    fi

    # kdialog (KDE)
    if command -v kdialog >/dev/null 2>&1; then
        kdialog --passivepopup "$message" 5 --title "$title"
        return 0
    fi

    # zenity (fallback)
    if command -v zenity >/dev/null 2>&1; then
        zenity --notification --window-icon="info" --text="$title: $message"
        return 0
    fi

    # wall (terminal)
    if command -v wall >/dev/null 2>&1; then
        echo "$title: $message" | wall
        return 0
    fi

    echo "No notification method available."
    return 1
}

enable_notifications
send_notification "Flow-Mode disable" "Notifications are back!"
