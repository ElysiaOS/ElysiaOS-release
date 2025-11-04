#!/bin/bash

set -e

# === Add ElysiaOS Repo ===
echo "[INFO] Checking for ElysiaOS repository in pacman.conf..."
if ! grep -q '^\[elysiaos-repo\]' /etc/pacman.conf; then
    echo "[INFO] Adding ElysiaOS repository to pacman.conf..."
    awk '/^\[core\]/{print; getline; print; print "\n[elysiaos-repo]\nSigLevel = Optional DatabaseOptional\nServer = https://raw.githubusercontent.com/ElysiaOS/elysiaos-repo/refs/heads/main/$arch"; next}1' /etc/pacman.conf > /etc/pacman.conf.tmp && mv /etc/pacman.conf.tmp /etc/pacman.conf
else
    echo "[INFO] ElysiaOS repository already exists, skipping."
fi

# === Add Multilib Repo ===
echo "[INFO] Checking for multilib repository in pacman.conf..."
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    echo "[INFO] Adding ARCH Multilib repository to pacman.conf..."
    awk '/^\[core\]/{print; getline; print; print "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist"; next}1' /etc/pacman.conf > /etc/pacman.conf.tmp && mv /etc/pacman.conf.tmp /etc/pacman.conf
else
    echo "[INFO] Multilib repository already exists, skipping."
fi

pacman -Syyy --noconfirm || true

# === Update system identity ===
echo "[INFO] Updating ElysiaOS..."
echo "elysiaos" > /etc/hostname

cat > /etc/os-release << 'EOF'
NAME="ElysiaOS"
PRETTY_NAME="ElysiaOS"
ID=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://www.elysiaos.live"
DOCUMENTATION_URL="https://www.elysiaos.live"
SUPPORT_URL="https://github.com/Matsko3/ElysiaOS"
BUG_REPORT_URL="https://github.com/Matsko3/ElysiaOS/issues"
PRIVACY_POLICY_URL="https://www.elysiaos.live/privacy-policy"
LOGO=elysiaos
EOF

cat > /etc/lsb-release << 'EOF'
DISTRIB_ID=ElysiaOS
DISTRIB_RELEASE="rolling"
DISTRIB_DESCRIPTION="ElysiaOS"
EOF

echo "Installing rest files dotfiles and extra packages"

# === Check for yay ===
echo "[+] Checking for yay..."
if ! command -v yay &>/dev/null; then
    echo "[!] yay not found. Installing yay..."
    pacman -S --needed --noconfirm git base-devel yay
else
    echo "[✓] yay is already installed."
fi

# === Package Install Section ===
echo "[+] Installing Required packages..."

# === Package Install Section ===
echo "[+] Checking and installing available packages..."

PACKAGES=(
  thunar hyprland starship downgrade
  wlogout swww kitty kew btop fastfetch hyprcursor hyprgraphics
  hypridle hyprland-qt-support hyprlock hyprpicker hyprutils
  xdg-desktop-portal-hyprland xdg-desktop-portal-gnome gnome-text-editor
  xdg-desktop-portal xfce4-settings xfce4-taskmanager gsettings-desktop-schemas
  gsettings-system-schemas qt5-base qt5-multimedia qt5-svg qt5-wayland qt5ct
  qt6-base qt6-wayland qt6ct zip libzip file-roller unzip thunar-archive-plugin
  noto-fonts ttf-jetbrains-mono-nerd auto-cpufreq
  python python-cairo python-installer python-numpy youtube-search-python
  python-pillow python-pip python-pipx python-psutil python-tqdm
  sublime-text-4 grim xclip wl-clipboard libnotify lm_sensors
  clipnotify copyq gpu-screen-recorder gpu-screen-recorder-ui
  gpu-screen-recorder-notification playerctl xkb-switch brightnessctl
  pipewire-pulse ttf-jetbrains-mono granite
  qimgv sxiv sddm-eucalyptus-drop-elysiaos granite7 libhandy
  xorg-xhost polkit-gnome polkit-qt6 gnome-terminal
  ffmpegthumbnailer tumbler slurp bc coreutils dmenu
  ttf-dejavu ttf-ubuntu-font-family ttf-doulos-sil ttf-hanazono
  ttf-sazanami ttf-baekmuk ttf-arphic-uming
  noto-fonts-cjk noto-fonts-emoji ttf-firacode-nerd
  fcitx5 fcitx5-configtool mpv jq pamixer
  ffmpeg gst-libav qt6-multimedia-ffmpeg
  python-pypresence gparted signet-workspaces-elysiaos
  elysia-updater-elysiaos elysia-settings-elysiaos
  elysia-launcher
)

INSTALLABLE=()

for pkg in "${PACKAGES[@]}"; do
  if pacman -Ss "^$pkg$" > /dev/null; then
    INSTALLABLE+=("$pkg")
  else
    echo "[!] Skipping: $pkg not found in official repositories."
  fi
done

if [ ${#INSTALLABLE[@]} -gt 0 ]; then
  echo "[+] Installing available packages..."
  pacman -S --noconfirm --needed "${INSTALLABLE[@]}" || {
    echo "[!] Conflict detected. Retrying with overwrite..."
    pacman -S --noconfirm --needed --overwrite="*" "${INSTALLABLE[@]}"
  }
else
  echo "[!] No installable packages found in official repositories."
fi

# === Install Floorp Browser ===
echo "[+] Downloading Floorp browser..."

ln -sf /opt/floorp/floorp /usr/bin/floorp


SOURCE_DIR="/ElysiaOS-release"  # or use $(dirname "$0") if script is in the same dir
TARGET_USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" { print $1; exit }' /etc/passwd)
TARGET_HOME="/home/$TARGET_USER"

echo "[+] Detected user: $TARGET_USER"

# Function to copy files (used for both existing user and skel)
copy_dotfiles() {
    local dest_dir="$1"
    local owner="$2"
    
    echo "[+] Copying dotfiles to $dest_dir..."
    shopt -s dotglob  # Include hidden files
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    
    for file in "$SOURCE_DIR"/*; do
        filename=$(basename "$file")
        
        # Skip certain files
        [[ "$filename" == ".git" || "$filename" == "install.sh" || "$filename" == ".github" || "$filename" == "home" ]] && continue
        
        cp -rf "$file" "$dest_dir/"
        echo "[✓] Copied $filename to $dest_dir"
    done
    
    # Fix ownership if owner is specified
    if [[ -n "$owner" ]]; then
        chown -R "$owner:$owner" "$dest_dir"
    fi
}

# Copy dotfiles to existing user's home
copy_dotfiles "$TARGET_HOME" "$TARGET_USER"

# ALSO copy dotfiles to /etc/skel for future users
echo "[+] Setting up /etc/skel..."
copy_dotfiles "/etc/skel"

# Copy rofi binary if it exists
if [[ -f "$TARGET_HOME/bin/rofi" ]]; then
    echo "[+] Installing rofi to /usr/bin/..."
    cp "$TARGET_HOME/bin/rofi" /usr/bin/
fi

cp "$TARGET_HOME/bin/wallpaper-switch.sh" /usr/bin/
cp "$TARGET_HOME/bin/network_manager" /usr/local/bin/
cp -r "$TARGET_HOME/fonts" /usr/share/
cp "$TARGET_HOME/services/wallpaper-auto.service" /etc/systemd/user/
cp "$TARGET_HOME/services/wallpaper-auto.timer" /etc/systemd/user/
cp "$TARGET_HOME/services/floorp.desktop" /usr/share/applications/

rm /etc/locale.gen
pacman -S glibc --noconfirm --overwrite /etc/locale.gen

echo "[+] Setting up Services..."

systemctl --user enable pipewire wireplumber pipewire-pulse
systemctl --user enable wallpaper-auto.timer
systemctl --user enable wallpaper-auto.service

echo "[+] Changing themes..."
fc-cache -f -v

# === Install Plymouth ===
echo "[+] Setting up Plymouth..."
sleep 2
if ! pacman -Q plymouth &>/dev/null; then
    echo "[+] Installing Plymouth..."
    sudo pacman -S --noconfirm plymouth-elysiaos
    plymouth-set-default-theme elysiaos-style2
else
    echo "[✓] Plymouth is already installed."
    plymouth-set-default-theme elysiaos-style2
fi

# === Edit mkinitcpio.conf to add plymouth ===
MKINITCONF="/etc/mkinitcpio.conf"
if ! grep -E "^HOOKS\s*=.*\bplymouth\b" "$MKINITCONF"; then
    echo "[+] Adding plymouth to mkinitcpio.conf HOOKS..."
    sudo sed -i 's/\(HOOKS\s*=(.*base udev\)/\1 plymouth/' "$MKINITCONF"
else
    echo "[✓] Plymouth already present in mkinitcpio.conf."
fi

# === Rebuild initramfs ===
echo "[+] Rebuilding initramfs with mkinitcpio..."
sudo mkinitcpio -p linux

# === Copy Plymouth Theme ===
echo "[+] Installing Plymouth theme..."
sudo cp -r plymouth/themes /usr/share/plymouth/
sudo plymouth-set-default-theme -R elysiaos-style2

# === Ensure /etc/plymouth/plymouthd.conf is correct ===
PLYMOUTH_CONF="/etc/plymouth/plymouthd.conf"
EXPECTED_THEME="Theme=elysiaos-style2"
EXPECTED_DELAY="ShowDelay=2"

echo "[+] Verifying $PLYMOUTH_CONF..."

if [ ! -f "$PLYMOUTH_CONF" ]; then
    echo "[+] Creating $PLYMOUTH_CONF..."
    echo -e "[Daemon]\n$EXPECTED_THEME\n$EXPECTED_DELAY" | sudo tee "$PLYMOUTH_CONF" >/dev/null
else
    # Ensure [Daemon] section exists
    if ! grep -q "^\[Daemon\]" "$PLYMOUTH_CONF"; then
        echo "[+] Adding [Daemon] section..."
        echo -e "\n[Daemon]\n$EXPECTED_THEME\n$EXPECTED_DELAY" | sudo tee -a "$PLYMOUTH_CONF" >/dev/null
    else
        # Fix Theme line inside [Daemon]
        sudo sed -i '/^\[Daemon\]/,/^\[.*\]/{s/^Theme=.*/'"$EXPECTED_THEME"'/}' "$PLYMOUTH_CONF"
        # Fix ShowDelay line
        if grep -q "^ShowDelay=" "$PLYMOUTH_CONF"; then
            sudo sed -i '/^\[Daemon\]/,/^\[.*\]/{s/^ShowDelay=.*/'"$EXPECTED_DELAY"'/}' "$PLYMOUTH_CONF"
        else
            sudo sed -i '/^\[Daemon\]/a '"$EXPECTED_DELAY" "$PLYMOUTH_CONF"
        fi
    fi
fi

# === Rebuild initramfs again ===
echo "[+] Rebuilding initramfs again after theme setup..."
sudo mkinitcpio -p linux

# === SDDM Setup ===
echo "[+] Setting up SDDM and applying eucalyptus-drop theme..."

# 1. Install SDDM if not found
if ! command -v sddm &>/dev/null; then
    echo "[!] sddm not found. Installing..."
    sudo pacman -S --noconfirm sddm
else
    echo "[✓] sddm is already installed."
fi

# 2. Enable SDDM as the display manager
if ! systemctl is-enabled sddm &>/dev/null; then
    echo "[+] Enabling SDDM as default display manager..."
    sudo systemctl enable sddm
else
    echo "[✓] SDDM is already enabled."
fi

# 4. Modify /etc/sddm.conf to use the theme
SDDM_CONF="/etc/sddm.conf"

if [ ! -f "$SDDM_CONF" ]; then
    echo "[+] Creating new /etc/sddm.conf with eucalyptus-drop-elysiaos theme..."
    echo -e "[Theme]\nCurrent=eucalyptus-drop-elysiaos" | sudo tee "$SDDM_CONF" >/dev/null
else
    if grep -q "^\[Theme\]" "$SDDM_CONF"; then
        if grep -q "^Current=" <(awk '/^\[Theme\]/{flag=1;next}/^\[.*\]/{flag=0}flag' "$SDDM_CONF"); then
            echo "[+] Updating existing 'Current=' in [Theme] section..."
            sudo sed -i '/^\[Theme\]/,/^\[/{s/^Current=.*/Current=eucalyptus-drop-elysiaos/}' "$SDDM_CONF"
        else
            echo "[+] Adding 'Current=' under existing [Theme] section..."
            sudo sed -i '/^\[Theme\]/a Current=eucalyptus-drop-elysiaos' "$SDDM_CONF"
        fi
    else
        echo "[+] Appending new [Theme] section..."
        echo -e "\n[Theme]\nCurrent=eucalyptus-drop-elysiaos" | sudo tee -a "$SDDM_CONF" >/dev/null
    fi
fi


# === Copy GRUB Theme ===
echo "[+] Installing GRUB theme..."
GRUB_THEME_SRC="GRUB-THEME/ElysianRealm"
GRUB_THEME_DEST="/boot/grub/themes/ElysianRealm"
sudo mkdir -p /boot/grub/themes
sudo cp -r "$GRUB_THEME_SRC" /boot/grub/themes/

# === Set GRUB_THEME in grub config ===
GRUB_FILE="/etc/default/grub"
THEME_LINE="GRUB_THEME=\"$GRUB_THEME_DEST/theme.txt\""

if grep -q "^GRUB_THEME=" "$GRUB_FILE"; then
    sudo sed -i "s|^GRUB_THEME=.*|$THEME_LINE|" "$GRUB_FILE"
else
    echo "$THEME_LINE" | sudo tee -a "$GRUB_FILE" >/dev/null
fi

# === Set GRUB_CMDLINE_LINUX_DEFAULT ===
echo "[+] Updating GRUB_CMDLINE_LINUX_DEFAULT..."
GRUB_CMDLINE='GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0 usbcore.autosuspend=-1"'
sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|$GRUB_CMDLINE|" "$GRUB_FILE"

# === Regenerate grub.cfg ===
echo "[+] Regenerating GRUB config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

# === Cleanup: Remove unneeded setup files from home ===
echo "[+] Cleaning up files from home directory..."
rm -rf "$TARGET_HOME/SDDM" \
       "$TARGET_HOME/GRUB-THEME" \
       "$TARGET_HOME/assets" \
       "$TARGET_HOME/plymouth" \
       "$TARGET_HOME/fonts" \
       "$TARGET_HOME/services" \
       "$TARGET_HOME/ElysiaOS-release" \
       "$TARGET_HOME/README.md"

rm "$TARGET_HOME/os.sh"

sleep 2
rm -rf "/ElysiaOS-release"

echo
echo "[+] ElysiaOS installation complete!"
echo

