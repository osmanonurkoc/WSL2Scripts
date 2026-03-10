#!/bin/bash

# --- COLORS ---
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}>>> Starting Package Setup...${NC}"

# --- PACKAGE LISTS ---
ESSENTIAL_PKGS="zsh git build-essential htop neofetch tree aria2 eza sed wget curl figlet lolcat rename cryptsetup unzip"
OPTIONAL_PKGS="gimp inkscape gparted gnome-tweaks nemo xed"

# --- INSTALLATION MENU ---
echo -e "\n${YELLOW}>>> SELECT INSTALLATION TYPE <<<${NC}"
echo "1) Essential Packages Only [DEFAULT]"
echo "   (Terminal tools, CLI utilities, development basics)"
echo "2) Full Installation"
echo "   (Includes GUI & Graphic tools: GIMP, Inkscape, GParted, Nemo, etc.)"

read -p "Enter a number (1-2) [Press Enter for 1]: " install_choice

# --- UPDATE REPOSITORIES ---
echo -e "\n${YELLOW}>>> Updating package lists...${NC}"
sudo apt update

# --- INSTALLATION LOGIC ---
if [ "$install_choice" == "2" ]; then
    echo -e "${GREEN}>>> Performing FULL Installation...${NC}"
    sudo apt install -y $ESSENTIAL_PKGS $OPTIONAL_PKGS
else
    echo -e "${GREEN}>>> Performing ESSENTIAL Installation...${NC}"
    sudo apt install -y $ESSENTIAL_PKGS
fi

echo -e "\n${CYAN}>>> PACKAGE SETUP COMPLETED! <<<${NC}"
