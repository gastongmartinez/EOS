#!/usr/bin/env bash

if [ $EUID -eq 0 ];
then
   echo "Este script debe usarse con un usuario regular."
   echo "Saliendo..."
   exit 1
fi

#################### Instalacion Extensiones Gnome ######################    
read -rp "Instalar Extensiones Gnome? (S/N): " EG
if [ "$EG" == 'S' ]; then    
    EXTS=(
        'gnome-shell-extension-arc-menu'
        'gnome-shell-extension-dash-to-dock'
        'gnome-shell-extension-dash-to-panel'
        'gnome-shell-extension-vitals-git'
        'gnome-shell-extension-blur-my-shell-git'
        'gnome-shell-extension-systemd-manager'
        'gnome-shell-extension-tiling-assistant'
        'gnome-shell-extension-tweaks-system-menu-git'
        'gnome-shell-extension-quake-mode-git'
        'gnome-shell-extension-sound-output-device-chooser'
        'gnome-shell-extension-no-overview'
        'gnome-shell-extension-pop-shell'
        
    )
    for EXT in "${EXTS[@]}"; do
        yay -S "$EXT" --noconfirm --needed
    done
fi
#######################################################################

#################### Instalacion de paquetes AUR ######################
AURPKGS=(
    'pamac-aur'
    'brave-bin'
    'zenmap'
    'autojump'
    'lf'
    'ttf-ms-fonts'
    'ttf-iosevka'
    'ttf-firacode'
    'font-manager'
    'ulauncher'
    'polybar'
    'whitesur-gtk-theme'
    'whitesur-icon-theme-git'
    'whitesur-cursor-theme-git'
)
for AUR in "${AURPKGS[@]}"; do
    yay -S "$AUR" --noconfirm --needed
done
#######################################################################

# Doom Emacs
if [ -d ~/.emacs.d ]; then
    rm -Rf ~/.emacs.d
fi
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install

# NeoVim
mkdir -p ~/.config/nvim
git clone https://github.com/gastongmartinez/Nvim ~/.config/nvim

# Android
read -rp "Instalar Android Studio? (S/N): " AS
if [ "$AS" == 'S' ]; then
    if [ ! -d ~/Apps ]; then
        mkdir ~/Apps
    fi
    cd ~/Apps || return
    wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2020.3.1.25/android-studio-2020.3.1.25-linux.tar.gz 
    tar -xzf android-studio-2020.3.1.25-linux.tar.gz
    rm android-studio-2020.3.1.25-linux.tar.gz
    wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_2.5.3-stable.tar.xz
    tar xf flutter_linux_2.5.3-stable.tar.xz
    rm flutter_linux_2.5.3-stable.tar.xz
    cd ~ || return
fi

# Jetbrains Nerd Fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.local/share/fonts
fc-cache -f -v
rm JetBrainsMono.zip

# ZSH
if [ ! -d ~/.local/share/zsh ]; then
    mkdir ~/.local/share/zsh
fi
touch ~/.zshrc
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.local/share/zsh/powerlevel10k
{
    echo 'source ~/.local/share/zsh/powerlevel10k/powerlevel10k.zsh-theme'
    echo 'source /usr/share/autojump/autojump.zsh'
    echo 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh'
    echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
    echo -e '\n# History in cache directory:'
    echo 'HISTSIZE=10000'
    echo 'SAVEHIST=10000'
    echo 'HISTFILE=~/.cache/zshhistory'
    echo 'setopt appendhistory'
    echo 'setopt sharehistory'
    echo 'setopt incappendhistory'
    echo 'JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk'
    echo 'export PATH="$HOME/Apps/flutter/bin:$HOME/.local/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"'
} >>~/.zshrc
chsh -s /usr/bin/zsh