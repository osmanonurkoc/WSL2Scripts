#!/bin/bash

# --- COLORS ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}>>> Starting WSL GUI Theme Configuration Script @osmanonurkoc...${NC}"

# --- 1. INTERACTIVE THEME SELECTION ---

# A. Theme Mode Selection
echo -e "\n${YELLOW}>>> THEME MODE SELECTION <<<${NC}"
echo "1) Light"
echo "2) Dark [DEFAULT]"
read -p "Select mode (1-2) [Press Enter for 2]: " mode_choice

if [ "$mode_choice" == "1" ]; then
    THEME_MODE="Light"
    PREFER_DARK=0
else
    THEME_MODE="Dark"
    PREFER_DARK=1
fi

# B. Mint-Y Accent Color Selection
echo -e "\n${YELLOW}>>> MINT-Y ACCENT COLOR SELECTION <<<${NC}"
echo "1) Green (Base)   5) Orange     9) Teal"
echo "2) Aqua           6) Pink      10) Sand"
echo "3) Blue [DEFAULT] 7) Purple"
echo "4) Grey           8) Red"
read -p "Select color (1-10) [Press Enter for 3]: " color_choice

case $color_choice in
    1) ACCENT="Green" ;;
    2) ACCENT="Aqua" ;;
    4) ACCENT="Grey" ;;
    5) ACCENT="Orange" ;;
    6) ACCENT="Pink" ;;
    7) ACCENT="Purple" ;;
    8) ACCENT="Red" ;;
    9) ACCENT="Teal" ;;
    10) ACCENT="Sand" ;;
    *) ACCENT="Blue" ;; # Default
esac

# Construct the GTK Theme Name based on selections
if [ "$THEME_MODE" == "Dark" ]; then
    if [ "$ACCENT" == "Green" ]; then
        GTK_THEME="Mint-Y-Dark"
    else
        GTK_THEME="Mint-Y-Dark-$ACCENT"
    fi
else
    if [ "$ACCENT" == "Green" ]; then
        GTK_THEME="Mint-Y"
    else
        GTK_THEME="Mint-Y-$ACCENT"
    fi
fi

# C. Papirus Folder Color Selection
echo -e "\n${YELLOW}>>> PAPIRUS FOLDER COLOR SELECTION <<<${NC}"
echo "Available colors:"
echo "adwaita, black, blue, bluegrey, breeze, brown, carmine, cyan,"
echo "darkcyan, deeporange, green, grey, indigo, magenta, nordic,"
echo "orange, palebrown, paleorange, pink, red, teal, violet, white,"
echo "yaru, yellow"
read -p "Enter folder color from the list above [Press Enter for 'blue']: " folder_choice

# Validate folder choice
VALID_FOLDERS="adwaita black blue bluegrey breeze brown carmine cyan darkcyan deeporange green grey indigo magenta nordic orange palebrown paleorange pink red teal violet white yaru yellow"

if [[ -z "$folder_choice" ]]; then
    ICON_COLOR="blue"
elif [[ " $VALID_FOLDERS " =~ " $folder_choice " ]]; then
    ICON_COLOR="$folder_choice"
else
    echo -e "${RED}Invalid color selected. Defaulting to 'blue'.${NC}"
    ICON_COLOR="blue"
fi

# Fixed Settings
ICON_THEME="Papirus"
CURSOR_THEME="Bibata-Modern-Classic" # Default Mint or DMZ-White
FONT_NAME="Ubuntu 10"  # Or any font available on your system

echo -e "\n${GREEN}Applying Configuration: GTK Theme -> $GTK_THEME | Icon Color -> $ICON_COLOR${NC}\n"

# --- 2. PREPARATION & PPA INTEGRATION ---
echo -e "${YELLOW}>>> Installing prerequisites for PPA management...${NC}"
sudo apt update
sudo apt install -y software-properties-common wget

echo -e "${YELLOW}>>> Adding Papirus PPA repository...${NC}"
sudo add-apt-repository -y ppa:papirus/papirus
sudo apt update

# --- 3. INSTALL NECESSARY PACKAGES ---
echo -e "${YELLOW}>>> Installing necessary theme packages and tools...${NC}"

PACKAGES=(
    mint-themes
    papirus-icon-theme
    qt5ct
    qt5-style-plugins
    gtk2-engines-murrine
    gtk2-engines-pixbuf
    dbus-x11
    libglib2.0-bin
)

if apt-cache search qt6ct | grep -q qt6ct; then
    PACKAGES+=(qt6ct)
fi

sudo apt install -y "${PACKAGES[@]}"

# --- 4. INSTALL AND CONFIGURE PAPIRUS FOLDERS ---
echo -e "${YELLOW}>>> Installing 'papirus-folders' tool manually...${NC}"
wget -qO- https://git.io/papirus-folders-install | sudo sh

echo -e "${YELLOW}>>> Setting Papirus icon folder color to $ICON_COLOR...${NC}"
sudo papirus-folders -C "$ICON_COLOR" --theme Papirus

# --- 5. GTK-3.0 CONFIGURATION ---
echo -e "${YELLOW}>>> Configuring GTK-3.0 settings...${NC}"
mkdir -p "$HOME/.config/gtk-3.0"

cat << EOF > "$HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=$FONT_NAME
gtk-cursor-theme-name=$CURSOR_THEME
gtk-application-prefer-dark-theme=$PREFER_DARK
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintmedium
EOF

# --- 6. GTK-4.0 CONFIGURATION ---
echo -e "${YELLOW}>>> Configuring GTK-4.0 settings...${NC}"
mkdir -p "$HOME/.config/gtk-4.0"
cp "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

# --- 7. GTK-2.0 CONFIGURATION ---
echo -e "${YELLOW}>>> Configuring GTK-2.0 settings...${NC}"
cat << EOF > "$HOME/.gtkrc-2.0"
include "/usr/share/themes/$GTK_THEME/gtk-2.0/gtkrc"
gtk-icon-theme-name="$ICON_THEME"
gtk-font-name="$FONT_NAME"
gtk-cursor-theme-name="$CURSOR_THEME"
EOF

# --- 8. GSETTINGS / DCONF SETTINGS ---
echo -e "${YELLOW}>>> Updating GSettings database...${NC}"

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
gsettings set org.gnome.desktop.interface font-name "$FONT_NAME"
gsettings set org.gnome.desktop.interface overlay-scrolling false
gsettings set org.gnome.desktop.interface color-scheme "$([ "$THEME_MODE" == "Dark" ] && echo 'prefer-dark' || echo 'prefer-light')"

# --- 9. QT5 AND QT6 CONFIGURATION ---
echo -e "${YELLOW}>>> Configuring Qt (qt5ct/qt6ct) settings...${NC}"

mkdir -p "$HOME/.config/qt5ct"
mkdir -p "$HOME/.config/qt6ct"

cat << EOF > "$HOME/.config/qt5ct/qt5ct.conf"
[Appearance]
icon_theme=$ICON_THEME
standard_dialogs=default
style=gtk2
custom_palette=false

[Fonts]
fixed="Monospace,10,-1,5,50,0,0,0,0,0"
general="$FONT_NAME"
EOF

if command -v qt6ct >/dev/null 2>&1; then
    cp "$HOME/.config/qt5ct/qt5ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"
fi

# --- 10. ENVIRONMENT VARIABLES CHECK ---
echo -e "${YELLOW}>>> Checking environment variables...${NC}"

SHELL_CONFIG="$HOME/.zshrc"
[ ! -f "$SHELL_CONFIG" ] && SHELL_CONFIG="$HOME/.bashrc"

if ! grep -q "QT_QPA_PLATFORMTHEME=qt5ct" "$SHELL_CONFIG"; then
    echo '' >> "$SHELL_CONFIG"
    echo '# For Qt applications to recognize the theme' >> "$SHELL_CONFIG"
    echo 'export QT_QPA_PLATFORMTHEME=qt5ct' >> "$SHELL_CONFIG"
    echo -e "${GREEN} -> QT_QPA_PLATFORMTHEME variable added to $SHELL_CONFIG.${NC}"
else
    echo -e "${GREEN} -> QT_QPA_PLATFORMTHEME is already set.${NC}"
fi

if ! grep -q "XCURSOR_PATH" "$SHELL_CONFIG"; then
     echo 'export XCURSOR_PATH=/usr/share/icons:~/.icons' >> "$SHELL_CONFIG"
fi

echo -e ""
echo -e "${GREEN}>>> PROCESS COMPLETED! <<<${NC}"
echo -e "Please close and reopen your WSL terminal for the changes to take full effect."
echo -e "You can test by opening 'nautilus', 'gedit' (GTK) or 'vlc', 'qterminal' (Qt)."
