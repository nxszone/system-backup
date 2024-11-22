#!/bin/bash

# Ensure a backup archive or folder is specified
if [ $# -lt 1 ]; then
    echo "Usage: $0 <backup_file_or_directory> [-d (dotfiles)] [-b (browsers)] [-a (apps)] [-s (ssh)] [-p (packages)] [-all (everything)]"
    exit 1
fi

# Extract or use the provided backup folder
BACKUP_SOURCE="$1"
if [[ "$BACKUP_SOURCE" == *.tar.gz ]]; then
    TEMP_DIR=$(mktemp -d)
    echo "Extracting $BACKUP_SOURCE to $TEMP_DIR"
    tar -xzvf "$BACKUP_SOURCE" -C "$TEMP_DIR" >/dev/null 2>&1
    BACKUP_DIR="$TEMP_DIR"
else
    BACKUP_DIR="$BACKUP_SOURCE"
fi

# Function to restore files/directories
restore() {
    SRC="$1"
    DEST="$2"
    if [ -e "$SRC" ]; then
        echo "Restoring $SRC to $DEST"
        cp -r --preserve=all "$SRC" "$DEST"
    else
        echo "Skipping $SRC (not found)"
    fi
}

# Restore functions for each backup type
restore_dotfiles() {
    echo "Restoring dotfiles..."
    restore "$BACKUP_DIR/dotfiles/.bashrc" "$HOME/"
    restore "$BACKUP_DIR/dotfiles/.zshrc" "$HOME/"
    restore "$BACKUP_DIR/dotfiles/.vimrc" "$HOME/"
    restore "$BACKUP_DIR/dotfiles/.config" "$HOME/"
    restore "$BACKUP_DIR/dotfiles/.local/share" "$HOME/.local/"
}

restore_browsers() {
    echo "Restoring browser profiles..."
    restore "$BACKUP_DIR/browsers/.mozilla" "$HOME/"
    restore "$BACKUP_DIR/browsers/google-chrome" "$HOME/.config/"
    restore "$BACKUP_DIR/browsers/chromium" "$HOME/.config/"
    restore "$BACKUP_DIR/browsers/brave-browser" "$HOME/.config/"
}

restore_apps() {
    echo "Restoring application settings..."
    restore "$BACKUP_DIR/app_configs/Code" "$HOME/.config/"
    restore "$BACKUP_DIR/app_configs/spotify" "$HOME/.config/"
    restore "$BACKUP_DIR/app_configs/discord" "$HOME/.config/"
}

restore_ssh() {
    echo "Restoring SSH keys..."
    restore "$BACKUP_DIR/ssh/.ssh" "$HOME/"
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/"*
}

restore_packages() {
    echo "Restoring package lists..."
    if [ -f "$BACKUP_DIR/package_lists/debian_packages.txt" ]; then
        echo "Restoring Debian/Ubuntu packages..."
        sudo dpkg --set-selections < "$BACKUP_DIR/package_lists/debian_packages.txt"
        sudo apt-get dselect-upgrade -y
    fi
    if [ -f "$BACKUP_DIR/package_lists/arch_packages.txt" ]; then
        echo "Restoring Arch/Manjaro packages..."
        sudo pacman -S --needed - < "$BACKUP_DIR/package_lists/arch_packages.txt"
    fi
    if [ -f "$BACKUP_DIR/package_lists/flatpak_list.txt" ]; then
        echo "Restoring Flatpak packages..."
        xargs -a "$BACKUP_DIR/package_lists/flatpak_list.txt" -I{} flatpak install -y {}
    fi
    if [ -f "$BACKUP_DIR/package_lists/snap_list.txt" ]; then
        echo "Restoring Snap packages..."
        awk 'NR>1 {print $1}' "$BACKUP_DIR/package_lists/snap_list.txt" | xargs -I{} sudo snap install {}
    fi
}


# Handle arguments for specific restore options
shift # Remove the backup source from arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <backup_file_or_directory> [-d (dotfiles)] [-b (browsers)] [-a (apps)] [-s (ssh)] [-p (packages)] [-f (fonts)] [-c (scripts)] [-all (everything)]"
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        -d)
            restore_dotfiles
            ;;
        -b)
            restore_browsers
            ;;
        -a)
            restore_apps
            ;;
        -s)
            restore_ssh
            ;;
        -p)
            restore_packages
            ;;
        -all)
            restore_dotfiles
            restore_browsers
            restore_apps
            restore_ssh
            restore_packages
            ;;
        *)
            echo "Invalid option: $1"
            echo "Usage: $0 <backup_file_or_directory> [-d (dotfiles)] [-b (browsers)] [-a (apps)] [-s (ssh)] [-p (packages)] [-f (fonts)] [-c (scripts)] [-all (everything)]"
            exit 1
            ;;
    esac
    shift
done

# Clean up temporary directory if used
if [[ -n "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
    echo "Temporary files cleaned up."
fi

echo "Restore process completed successfully."
