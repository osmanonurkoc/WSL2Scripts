
# WSL2 Linux Mint Automation & Customization Scripts 🍃

A collection of scripts to automate the installation of Linux Mint on WSL2 and instantly transform it into a ready-to-use, aesthetically pleasing development environment. It takes a barebones WSL setup and turns it into a Windows-integrated workspace featuring a Catppuccin theme and stylish GUI apps.

### 📦 Contents & Features

-   **`Mint_Installer.ps1` & `Mint_Uninstaller.ps1`** Checks for required WSL2 features, downloads the latest Linux Mint image directly from GitHub, installs it, and performs the first launch automatically. When you're done or want a fresh start, the Uninstaller removes everything without leaving a trace.
    
-   **`WSL2Mint.exe`** A handy bridge utility that routes Linux scripts directly into your WSL environment. Set it as the default program for `.sh` files in Windows, and you can execute any Bash/Zsh script simply by double-clicking it!
    
-   **`1-Setup-Packages.sh`** Installs essential CLI tools for development (Zsh, Git, eza, htop, etc.). You can also choose the "Full Installation" from the interactive menu to include GUI tools like GIMP, Inkscape, and Nemo.
    
-   **`2-Setup-Mint-Y-Theme.sh`** Because WSL GUI apps shouldn't look like they're from the 90s. This script integrates Mint-Y (with Light/Dark modes and all accent colors) and Papirus icon themes. You can configure your preferences interactively during setup.
    
-   **`3-Setup-Zsh.sh`** Replaces Bash with Zsh and sets up a beautifully detailed, two-line Starship prompt featuring the **Catppuccin Mocha** color palette. It also includes lifesaver WSL-Windows integration aliases (like `copy` to send text to the Windows clipboard, or `exp` to open the current directory in Windows Explorer).
    

### 🚀 How to Use

1.  Open PowerShell in Windows and start the installation:
    
    PowerShell
    
    ```
    .\Mint_Installer.ps1
    
    ```
    
    _(The script will automatically request administrator privileges if needed. If a system restart is required, approve it. The setup will automatically resume exactly where it left off after you log back in.)_
    
2.  Once the installation is complete and the Linux Mint terminal opens, navigate to the directory where your scripts are located and make them executable:
    
    Bash
    
    ```
    chmod +x *.sh
    
    ```
    
3.  Build your environment by running the package, theme, and Zsh configuration scripts in order:
    
    Bash
    
    ```
    ./1-Setup-Packages.sh
    ./2-Setup-Mint-Y-Theme.sh
    ./3-Setup-Zsh.sh
    
    ```
    

> **⚡ Pro Tip (Double-Click Execution):** Want to skip the terminal commands in step 3? Right-click any `.sh` script in Windows Explorer, choose **"Open with"**, and select **`WSL2Mint.exe`** (make sure to check "Always use this app"). Once set, you can run all your Linux setup scripts directly by double-clicking them!

> **💡 Important Note:** To ensure the cool symbols in the terminal (Starship) render correctly instead of showing as broken boxes, make sure you have a **Nerd Font** (e.g., _MesloLGS NF_ or _FiraCode NF_) selected in your Windows Terminal settings!

## 📄 License
This project is licensed under the [GPL License](LICENSE).

---
*Created by [@osmanonurkoc](https://github.com/osmanonurkoc)*
