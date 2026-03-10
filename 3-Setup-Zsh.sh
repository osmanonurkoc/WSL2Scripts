#!/bin/bash

# --- COLORS ---
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}>>> Starting Universal WSL2 Zsh & Starship Setup @osmanonurkoc...${NC}"

# --- 0. DETECT WINDOWS USERNAME ---
echo -e "${YELLOW}>>> Detecting Windows username...${NC}"
# We use cmd.exe to get the variable from the Windows side to be 100% accurate
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')

if [ -z "$WIN_USER" ]; then
    echo -e "${RED}>>> Could not detect Windows username. Defaulting to 'Osman'.${NC}"
    WIN_USER="Osman"
else
    echo -e "${GREEN}>>> Windows User detected: ${WIN_USER}${NC}"
fi

# --- 1. LOCALE SELECTION MENU ---
echo -e "\n${CYAN}>>> SELECT YOUR SYSTEM LOCALE / LANGUAGE <<<${NC}"
echo "1) Turkish (tr_TR.UTF-8) [DEFAULT]"
echo "2) English (en_US.UTF-8)"
echo "3) Mandarin Chinese (zh_CN.UTF-8)"
echo "4) Hindi (hi_IN.UTF-8)"
echo "5) Spanish (es_ES.UTF-8)"
echo "6) French (fr_FR.UTF-8)"
echo "7) Arabic (ar_EG.UTF-8)"
echo "8) Bengali (bn_BD.UTF-8)"
echo "9) Russian (ru_RU.UTF-8)"
echo "10) Portuguese (pt_PT.UTF-8)"
echo "11) Urdu (ur_PK.UTF-8)"
echo "12) Indonesian (id_ID.UTF-8)"
echo "13) German (de_DE.UTF-8)"
echo "14) Japanese (ja_JP.UTF-8)"
echo "15) Korean (ko_KR.UTF-8)"

read -p "Enter a number (1-15) [Press Enter for 1]: " locale_choice

case $locale_choice in
    2) SELECTED_LOCALE="en_US.UTF-8" ;;
    3) SELECTED_LOCALE="zh_CN.UTF-8" ;;
    4) SELECTED_LOCALE="hi_IN.UTF-8" ;;
    5) SELECTED_LOCALE="es_ES.UTF-8" ;;
    6) SELECTED_LOCALE="fr_FR.UTF-8" ;;
    7) SELECTED_LOCALE="ar_EG.UTF-8" ;;
    8) SELECTED_LOCALE="bn_BD.UTF-8" ;;
    9) SELECTED_LOCALE="ru_RU.UTF-8" ;;
    10) SELECTED_LOCALE="pt_PT.UTF-8" ;;
    11) SELECTED_LOCALE="ur_PK.UTF-8" ;;
    12) SELECTED_LOCALE="id_ID.UTF-8" ;;
    13) SELECTED_LOCALE="de_DE.UTF-8" ;;
    14) SELECTED_LOCALE="ja_JP.UTF-8" ;;
    15) SELECTED_LOCALE="ko_KR.UTF-8" ;;
    *) SELECTED_LOCALE="tr_TR.UTF-8" ;; # Default fallback
esac

# --- 2. INSTALL PACKAGES ---
echo -e "${YELLOW}>>> Updating system and installing packages (zsh, git, curl, neofetch, wslu)...${NC}"
sudo apt update && sudo apt install -y zsh git curl wget neofetch wslu

# --- 3. GENERATE LOCALE ---
echo -e "${YELLOW}>>> Generating Locale ($SELECTED_LOCALE)...${NC}"
sudo locale-gen $SELECTED_LOCALE

# --- 4. INSTALL STARSHIP ---
if ! command -v starship >/dev/null 2>&1; then
    echo -e "${YELLOW}>>> Installing Starship Prompt...${NC}"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo -e "${GREEN}>>> Starship is already installed.${NC}"
fi

# --- 5. MANUAL PLUGIN INSTALLATION (No Framework) ---
PLUGIN_DIR="$HOME/.zsh/plugins"
mkdir -p "$PLUGIN_DIR"

echo -e "${YELLOW}>>> Installing Zsh Plugins manually...${NC}"

if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"
else
    git -C "$PLUGIN_DIR/zsh-autosuggestions" pull
fi

if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"
else
    git -C "$PLUGIN_DIR/zsh-syntax-highlighting" pull
fi

if [ ! -d "$PLUGIN_DIR/zsh-completions" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-completions "$PLUGIN_DIR/zsh-completions"
else
    git -C "$PLUGIN_DIR/zsh-completions" pull
fi

# --- 6. CONFIGURE STARSHIP THEME ---
echo -e "${YELLOW}>>> Creating Custom Starship configuration with Catppuccin Mocha...${NC}"
mkdir -p "$HOME/.config"

cat <<EOF > "$HOME/.config/starship.toml"
# Custom Two-Line Starship Config
# Optimized for WSL2 & Catppuccin Mocha

add_newline = true
scan_timeout = 2000
command_timeout = 2000
palette = "catppuccin_mocha"

[palettes.catppuccin_mocha]
rosewater = "#f5e0dc"
flamingo = "#f2cdcd"
pink = "#f5c2e7"
mauve = "#cba6f7"
red = "#f38ba8"
maroon = "#eba0ac"
peach = "#fab387"
yellow = "#f9e2af"
green = "#a6e3a1"
teal = "#94e2d5"
sky = "#89dceb"
sapphire = "#74c7ec"
blue = "#89b4fa"
lavender = "#b4befe"
text = "#cdd6f4"
subtext1 = "#bac2de"
subtext0 = "#a6adc8"
overlay2 = "#9399b2"
overlay1 = "#7f849c"
overlay0 = "#6c7086"
surface2 = "#585b70"
surface1 = "#45475a"
surface0 = "#313244"
base = "#1e1e2e"
mantle = "#181825"
crust = "#11111b"

## FIRST LINE/ROW: Info & Status
[username]
format = " [╭─\$user](\$style)@"
show_always = true
style_root = "bold red"
style_user = "bold mauve"

[hostname]
disabled = false
format = "[\$hostname](\$style) in "
ssh_only = false
style = "bold dimmed subtext0"
trim_at = "-"

[directory]
style = "bold lavender"
truncate_to_repo = true
truncation_length = 0
truncation_symbol = "repo: "

[sudo]
disabled = false

[git_status]
ahead = "⇡\${count}"
behind = "⇣\${count}"
deleted = "x"
diverged = "⇕⇡\${ahead_count}⇣\${behind_count}"
style = "text"

[cmd_duration]
disabled = false
format = "took [\$duration](\$style)"
style = "peach"
min_time = 1

## SECOND LINE/ROW: Prompt
[battery]
charging_symbol = ""
disabled = true
discharging_symbol = ""
full_symbol = ""

[[battery.display]]
disabled = false
style = "bold red"
threshold = 15

[[battery.display]]
disabled = true
style = "bold yellow"
threshold = 50

[[battery.display]]
disabled = true
style = "bold green"
threshold = 80

[time]
disabled = true
format = " 🕙 \$time(\$style)\n"
style = "text"
time_format = "%T"

[character]
error_symbol = " [×](bold red)"
success_symbol = " [╰─λ](bold green)"

# SYMBOLS
[status]
disabled = false
format = '[\[\$symbol\$status_common_meaning\$status_signal_name\$status_maybe_int\]](\$style)'
map_symbol = true
pipestatus = true
symbol = "🔴"

[aws]
symbol = " "

[conda]
symbol = " "

[dart]
symbol = " "

[docker_context]
symbol = " "

[elixir]
symbol = " "

[elm]
symbol = " "

[git_branch]
symbol = " "

[golang]
symbol = " "

[hg_branch]
symbol = " "

[java]
symbol = " "

[julia]
symbol = " "

[nim]
symbol = " "

[nix_shell]
symbol = " "

[nodejs]
symbol = " "

[package]
symbol = " "

[perl]
symbol = " "

[php]
symbol = " "

[python]
symbol = " "

[ruby]
symbol = " "

[rust]
symbol = " "

[swift]
symbol = "ﯣ "
EOF

# --- 7. CONFIGURE .zshrc ---
echo -e "${YELLOW}>>> Configuring .zshrc...${NC}"

if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%F_%T)"
    echo -e "${GREEN}>>> Old .zshrc backed up.${NC}"
fi

cat <<EOF > "$HOME/.zshrc"
# ~/.zshrc - Optimized for WSL2

# --- 1. HISTORY SETTINGS ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# --- 2. COMPLETION SYSTEM ---
fpath=($PLUGIN_DIR/zsh-completions/src \$fpath)
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# --- 3. OPTIONS ---
setopt AUTO_CD
setopt CORRECT
setopt INTERACTIVE_COMMENTS

# --- 4. ALIASES ---
# Basic Linux Commands
alias ll='ls -lh'
alias la='ls -lha'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'

# Git Commands
alias gs='git status'
alias gl='git pull'
alias gp='git push'
alias ga='git add .'
alias gc='git commit -m'

# System Commands
alias sudo='sudo -E'
alias update='sudo apt update && sudo apt upgrade -y'

# WSL2 & Windows Directory Integration
alias winhome="cd /mnt/c/Users/$WIN_USER"
alias windesk="cd /mnt/c/Users/$WIN_USER/Desktop"
alias windl="cd /mnt/c/Users/$WIN_USER/Downloads"

# WSL2 Tools & Windows Interoperability
alias exp="explorer.exe ."              # Opens the current directory in Windows File Explorer
alias copy="clip.exe"                   # Copies terminal output to the Windows clipboard (e.g., cat file.txt | copy)
alias paste="powershell.exe -command 'Get-Clipboard'" # Pastes text from the Windows clipboard to the terminal
alias open="wslview"                    # Opens a file or URL with the default Windows application

# --- 5. PLUGINS SOURCE ---
source $PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh
source $PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Adjusted autosuggestion color for better contrast with dark themes
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#585b70'

# --- 6. LOCALE & ENVIRONMENT ---
export LANG=$SELECTED_LOCALE
export LC_ALL=$SELECTED_LOCALE
export PATH="\$HOME/bin:\$HOME/.local/bin:\$PATH"
export QT_QPA_PLATFORMTHEME=qt5ct

# --- 7. WSL SPECIFIC: JUMP TO WINDOWS HOME ---
if grep -qi microsoft /proc/version 2>/dev/null; then
    WINHOME="/mnt/c/Users/$WIN_USER"
    if [[ "\$PWD" = "\$HOME" ]]; then
        cd "\$WINHOME"
    fi
fi

# --- 8. INITIALIZE STARSHIP ---
eval "\$(starship init zsh)"

# --- 9. NEOFETCH ---
if command -v neofetch >/dev/null 2>&1; then
    neofetch
fi
EOF

# --- 8. CHANGE DEFAULT SHELL ---
echo -e "${YELLOW}>>> Setting Zsh as default shell...${NC}"
TEST_ZSH=$(which zsh)
if [ "$SHELL" != "$TEST_ZSH" ]; then
    sudo chsh -s "$TEST_ZSH" "$USER"
    echo -e "${GREEN}>>> Shell changed. Please restart your terminal.${NC}"
else
    echo -e "${GREEN}>>> Default shell is already Zsh.${NC}"
fi

echo -e "\n${CYAN}>>> SETUP COMPLETED! <<<${NC}"
echo -e "NOTES:"
echo -e "1. Install a 'Nerd Font' in Windows (e.g., MesloLGS NF) and set it in your Terminal settings."
echo -e "2. Close and reopen your terminal to apply changes."
