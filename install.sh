#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Determine the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "    Starting Fedora Setup & Restore       "
echo "=========================================="

# 1. Enable RPM Fusion Repositories (For multimedia codecs & extra drivers)
echo "[1/5] Enabling RPM Fusion Repositories..."
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || true

# 2. Install Native DNF Packages
if [ -f "$DOTFILES_DIR/packages.txt" ]; then
    echo "[2/5] Installing DNF Packages from packages.txt..."
    sudo dnf install -y $(cat "$DOTFILES_DIR/packages.txt")
else
    echo "[2/5] packages.txt not found, skipping DNF installation."
fi

# 3. Install Flatpak Applications
if [ -f "$DOTFILES_DIR/flatpaks.txt" ] && command -v flatpak &> /dev/null; then
    echo "[3/5] Installing Flatpaks from flatpaks.txt..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    cat "$DOTFILES_DIR/flatpaks.txt" | xargs -r flatpak install -y flathub
else
    echo "[3/5] flatpaks.txt not found or Flatpak not installed, skipping."
fi

# 4. Helper Function to Safely Symlink Configurations
echo "[4/5] Symlinking configurations..."
mkdir -p "$HOME/.config"

link_config() {
    local src="$1"
    local dest="$2"

    if [ -d "$src" ] || [ -f "$src" ]; then
        if [ -e "$dest" ] || [ -h "$dest" ]; then
            echo "Backing up existing $(basename "$dest") to ~/.config/backup_old"
            mkdir -p "$HOME/.config/backup_old"
            mv "$dest" "$HOME/.config/backup_old/"
        fi
        ln -snf "$src" "$dest"
        echo "Linked: $src -> $dest"
    fi
}

# Link items inside .config (Add or remove based on your setup)
if [ -d "$DOTFILES_DIR/.config" ]; then
    for folder in "$DOTFILES_DIR/.config"/*; do
        if [ -e "$folder" ]; then
            basename_folder="$(basename "$folder")"
            link_config "$folder" "$HOME/.config/$basename_folder"
        fi
    done
fi

# 5. Link Home Directory Files (e.g., .bashrc or .fishrc if present)
if [ -f "$DOTFILES_DIR/home/.bashrc" ]; then
    echo "[5/5] Linking .bashrc..."
    ln -sf "$DOTFILES_DIR/home/.bashrc" "$HOME/.bashrc"
fi

echo "=========================================="
echo "   Installation Complete! Please Reboot   "
echo "=========================================="
