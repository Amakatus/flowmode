#!/bin/bash

set -e

# GNOME
if command -v gsettings &>/dev/null && \
    gsettings list-schemas | grep -q "org.gnome.desktop.notifications"; then
     gsettings set org.gnome.desktop.notifications show-banners false
fi

# KDE Plasma
if command -v qdbus &>/dev/null; then
    qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.setEnabled false 2>/dev/null || true
    qdbus org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications.CloseNotification 0 2>/dev/null || true
fi

# XFCE
if command -v xfconf-query &>/dev/null; then
    xfconf-query -c xfce4-notifyd -p /do-not-disturb -s true 2>/dev/null || true
fi

# MATE
if command -v dconf &>/dev/null; then
    dconf write /org/mate/notification-daemon/enable false 2>/dev/null || true
fi

# Cinnamon
if command -v gsettings &>/dev/null; then
    gsettings set org.cinnamon.desktop.notifications display-notifications false 2>/dev/null || true
fi

# LXQt
if pgrep lxqt-notificationd &>/dev/null; then
    pkill -SIGUSR1 lxqt-notificationd 2>/dev/null || true
fi

# libnotify (notify-osd)
if pgrep notify-osd &>/dev/null; then
    pkill notify-osd 2>/dev/null || true
fi

# Wayland (sway)
if command -v swaymsg &>/dev/null; then
    swaymsg 'output * inhibit_idle on' 2>/dev/null || true
fi

# Wayland (mako)
if pgrep mako &>/dev/null; then
    pkill -SIGUSR1 mako 2>/dev/null || true
fi

# Hyprland (swaync)
if pgrep swaync &>/dev/null; then
    swaync-client -dn 2>/dev/null || true
fi

