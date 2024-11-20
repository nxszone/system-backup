#!/bin/bash

# Backup destination
BACKUP_DIR="$HOME/system_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Subdirectories for organized backups
DOTFILES_DIR="$BACKUP_DIR/dotfiles"
BROWSERS_DIR="$BACKUP_DIR/browsers"
APPS_DIR="$BACKUP_DIR/app_configs"
SSH_DIR="$BACKUP_DIR/ssh"
PACKAGE_LISTS_DIR="$BACKUP_DIR/package_lists"

mkdir -p "$DOTFILES_DIR" "$BROWSERS_DIR" "$APPS_DIR" "$SSH_DIR" "$PACKAGE_LISTS_DIR"


# Function to copy files/directories with logging
backup() {
    SRC="$1"
    DEST="$2"
    if [ -e "$SRC" ]; then
        echo "Backing up $SRC to $DEST"
        cp -r --preserve=all "$SRC" "$DEST"
    else
        echo "Skipping $SRC (not found)"
    fi
}

# Function for each backup type
backup_dotfiles() {
    echo "Backing up dotfiles..."
    backup "$HOME/.bashrc" "$DOTFILES_DIR/"
    backup "$HOME/.zshrc" "$DOTFILES_DIR/"
    backup "$HOME/.vimrc" "$DOTFILES_DIR/"
    backup "$HOME/.config" "$DOTFILES_DIR/"
}

backup_browsers() {
    echo "Backing up browser profiles..."
    backup "$HOME/.mozilla" "$BROWSERS_DIR/"
    backup "$HOME/.config/google-chrome" "$BROWSERS_DIR/"
    backup "$HOME/.config/chromium" "$BROWSERS_DIR/"
    backup "$HOME/.config/brave-browser" "$BROWSERS_DIR/"
}

backup_apps() {
    echo "Backing up application settings..."
    backup "$HOME/.config/Code" "$APPS_DIR/"  # VS Code
    backup "$HOME/.config/spotify" "$APPS_DIR/"
    backup "$HOME/.config/discord" "$APPS_DIR/"
}

backup_ssh() {
    echo "Backing up SSH keys..."
    backup "$HOME/.ssh" "$SSH_DIR/"
}

backup_packages() {
    echo "Backing up package lists..."
    if command -v dpkg >/dev/null 2>&1; then
        echo "Saving Debian/Ubuntu package list..."
        dpkg --get-selections > "$PACKAGE_LISTS_DIR/debian_packages.txt"
    fi
    if command -v pacman >/dev/null 2>&1; then
        echo "Saving Arch/Manjaro package list..."
        pacman -Qqe > "$PACKAGE_LISTS_DIR/arch_packages.txt"
    fi
    if command -v flatpak >/dev/null 2>&1; then
        echo "Saving Flatpak package list..."
        flatpak list --columns=application > "$PACKAGE_LISTS_DIR/flatpak_list.txt"
    fi
    if command -v snap >/dev/null 2>&1; then
        echo "Saving Snap package list..."
        snap list > "$PACKAGE_LISTS_DIR/snap_list.txt"
    fi
}



compress_backup() {
    echo "Compressing backup..."
    tar -czvf "${BACKUP_DIR}.tar.gz" -C "$BACKUP_DIR" .
    rm -rf "$BACKUP_DIR"
    echo "Backup completed successfully. File saved as ${BACKUP_DIR}.tar.gz"
}

# Handle arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 -d (dotfiles) -b (browsers) -a (apps) -s (ssh) -p (packages) -f (fonts) -c (scripts) -all (everything)"
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        -d)
            backup_dotfiles
            ;;
        -b)
            backup_browsers
            ;;
        -a)
            backup_apps
            ;;
        -s)
            backup_ssh
            ;;
        -p)
            backup_packages
            ;;
        -all)
            backup_dotfiles
            backup_browsers
            backup_apps
            backup_ssh
            backup_packages
            ;;
        *)
            echo "Invalid option: $1"
            echo "Usage: $0 -d (dotfiles) -b (browsers) -a (apps) -s (ssh) -p (packages) -all (everything)"
            exit 1
            ;;
    esac
    shift
done

compress_backup
