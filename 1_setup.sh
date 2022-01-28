#!/usr/bin/env bash

# Validacion del usuario ejecutando el script
R_USER=$(id -u)
if [ "$R_USER" -ne 0 ];
then
    echo -e "\nDebe ejecutar este script como root o utilizando sudo.\n"
    exit 1
fi

read -rp "Establecer el password para root? (S/N): " PR
if [ "$PR" == 'S' ]; 
then
    passwd root
fi

USUARIO=$(grep "1000" /etc/passwd | awk -F : '{ print $1 }')

pacman -Syu

#######################  Hardware & Drivers  #######################
echo -e "\nSeleccion de paquetes para el hardware del equipo.\n"

# Virtualizacion
read -rp "Se instala en maquina virtual (S/N): " MV
if [ "$MV" == "S" ];
then
    read -rp "Indicar plataforma virtual 1=VirtualBox - 2=VMWare: " PLAT
    if [ "$PLAT" -eq 1 ] 2>/dev/null;
    then
        # VirtualBox Guest utils
        pacman -S virtualbox-guest-utils --noconfirm --needed
    else
        # Open-VM-Tools (WMWare)
        pacman -S open-vm-tools --noconfirm --needed
        pacman -S xf86-video-vmware --noconfirm --needed
        systemctl enable vmware-vmblock-fuse.service
        systemctl enable vmtoolsd.service
    fi
fi

# Bluetooth
read -rp "Desea instalar Bluetooth (S/N): " BT
if [ "$BT" == "S" ];
then
    pacman -S bluez --noconfirm --needed
    pacman -S bluez-utils --noconfirm --needed
    systemctl enable bluetooth
fi

# SSD
read -rp "Se instala en un SSD (S/N): " SSD
if [ "$SSD" == "S" ];
then
    pacman -S util-linux --noconfirm --needed
    systemctl enable fstrim.service
    systemctl enable fstrim.timer
fi

# Touchpad
read -rp "Instalar drivers para touchpad (S/N): " TOUCH
if [ "$TOUCH" == "S" ];
then
    pacman -S xf86-input-libinput --noconfirm --needed
fi

# ACPI 
read -rp "Instalar ACPI (S/N): " AC
if [ "$AC" == "S" ];
then   
    pacman -S acpi --noconfirm --needed
    pacman -S acpi_call --noconfirm --needed
    pacman -S acpid --noconfirm --needed
    systemctl enable acpid     
fi
####################################################################

# Swappiness
echo -e "vm.swappiness=10\n" >> /etc/sysctl.d/99-sysctl.conf

# SSH
systemctl enable sshd

# Network Manager
pacman -S network-manager-applet --noconfirm --needed
systemctl enable NetworkManager

# Teclado
localectl set-x11-keymap es pc105 winkeys

################################# GNOME ############################################
gnome () {
    pacman -S gnome --noconfirm --needed
    pacman -S gnome-extra --noconfirm --needed

    # GDM
    systemctl enable gdm
}
####################################################################################

################################## WM General ######################################
wm () {
    pacman -S dmenu --noconfirm --needed
    pacman -S rofi --noconfirm --needed
    pacman -S nitrogen --noconfirm --needed
    pacman -S feh --noconfirm --needed
    pacman -S picom --noconfirm --needed
    pacman -S lxappearance --noconfirm --needed
    pacman -S awesome --noconfirm --needed
    pacman -S bspwm --noconfirm --needed
    pacman -S sxhkd --noconfirm --needed
    
    sleep 2
    sed -i 's/Name=awesome/Name=Awesome/g' "/usr/share/xsessions/awesome.desktop"
    sed -i 's/Name=bspwm/Name=BSPWM/g' "/usr/share/xsessions/bspwm.desktop"
}
####################################################################################

################################### Escritorios ####################################
ESCRITORIOS="GNOME WMs Siguiente"
echo -e "\nSeleccione el entorno a instalar:"
select escritorio in $ESCRITORIOS;
do
    if [ "$escritorio" == "GNOME" ];
    then
        echo -e "\nInstalando Gnome"
        sleep 2
        gnome
    elif [ "$escritorio" == "WMs" ];
    then
        echo -e "\nInstalando Window Managers"
        sleep 2
        wm
    else
        break
    fi
    echo -e "\nSeleccione el entorno a instalar:"
    REPLY=""
done
####################################################################################

################################### SDDM ###########################################
read -rp "Instalar SDDM? (S/N): " SD
if [ "$SD" == 'S' ]; 
then
    pacman -S sddm sddm-kcm --noconfirm --needed
    systemctl disable gdm
    systemctl enable sddm.service
fi
####################################################################################

############################### Pacman ################################
PACMANPKGS=(
    #### Compresion ####
    'p7zip'

    #### Fuentes ####
    'terminus-font'
    'ttf-roboto'
    'ttf-roboto-mono'
    'powerline-fonts'
    'ttf-ubuntu-font-family'
    'ttf-font-awesome'
    'ttf-cascadia-code'
    'ttf-fira-code'
    'ttf-carlito'
    'ttf-caladea'

    #### WEB ####
    'wget'
    'curl'
    'chromium'
    'firefox'
    'thunderbird'
    'remmina'
    'qbittorrent'

    #### Shells ####
    'bash-completion'
    'zsh'
    'zsh-theme-powerlevel10k'
    'zsh-autosuggestions'
    'zsh-syntax-highlighting'
    'shellcheck'

    #### Terminales ####
    'alacritty'

    #### Archivos ####
    'thunar'
    'thunar-archive-plugin'
    'thunar-media-tags-plugin'
    'thunar-volman'
    'fd'
    'mc'
    'vifm'
    'fzf'
    'stow'
    'ripgrep'
    'autofs'

    #### Sistema ####
    'conky'
    'htop'
    'bpytop'
    'neofetch'
    'man'
    'os-prober'
    'pkgfile'
    'lshw'
    'plank'
    'powerline'
    'flameshot'
    'ktouch'
    'foliate'
    'dconf-editor'
    'cockpit'
    'cockpit-machines'
    'powertop'
    
    #### Editores ####
    'neovim'
    'emacs'
    'code'
    'libreoffice-fresh'
    'libreoffice-fresh-es'

    #### Multimedia ####
    'vlc'
    'clementine'
    'mpv'
    'handbrake'

    #### Juegos ####
    'chromium-bsu'
    
    #### Redes ####
    'firewalld'
    'nmap'
    'wireshark-qt'
    'inetutils'
    'dnsutils'
    'nfs-utils'
    'nss-mdns'

    #### Diseño ####
    'gimp'
    'inkscape'
    'krita'
    'blender'
    #'freecad'

    #### DEV ####
    'the_silver_searcher'
    'gcc'
    'clang'
    'filezilla'
    'go'
    'rust'
    'python'
    'python-pip'
    'jdk8-openjdk'
    'pycharm-community-edition'
    'intellij-idea-community-edition'
    'nodejs'
    'npm'
    'yarn'
    'lazygit'

    #### Bases de datos ####
    'postgresql'
    'postgis'
    'pgadmin4'
    'mariadb'
)

# Instalacion de paquetes desde los repositorios de Arch 
for PAC in "${PACMANPKGS[@]}"; do
    pacman -S "$PAC" --noconfirm --needed
done

#######################################################################

############################ Virtualización ###########################
read -rp "Instalar virtualizacion? (S/N): " VIRT
if [ "$VIRT" == 'S' ]; then
    PAQUETES=(
        'virt-manager'
        'qemu'
        'qemu-arch-extra'
        'ovmf'
        'ebtables'
        'vde2'
        'dnsmasq'
        'bridge-utils'
        'virtualbox'
    )
    for PAQ in "${PAQUETES[@]}"; do
        pacman -S "$PAQ" --noconfirm --needed
    done

    # Activacion libvirt para KVM
    systemctl enable libvirtd
    usermod -G libvirt -a "$USUARIO"
fi

#######################################################################

# Firewall
systemctl enable --now firewalld.service
firewall-cmd --set-default-zone=public
firewall-cmd --add-service=ssh --permanent

# Cockpit
systemctl enable --now cockpit.socket
firewall-cmd --add-service=cockpit
firewall-cmd --add-service=cockpit --permanent

# Wallpapers
git clone https://github.com/gastongmartinez/wallpapers.git /usr/share/backgrounds/wallpapers/

{
    echo "[User]"
    echo "Icon=/var/lib/AccountsService/icons/$USUARIO"
    echo "SystemAccount=false    "
} > /var/lib/AccountsService/users/"$USUARIO"

cp /usr/share/backgrounds/wallpapers/Fringe/fibonacci3.jpg /var/lib/AccountsService/icons/"$USUARIO"

# Resolucion Grub
read -rp "Configurar Grub en 1920x1080? (S/N): " GB
if [ "$GB" == 'S' ]; then
    sed -i 's/auto/1920x1080x32/g' "/etc/default/grub"
    grub-mkconfig -o /boot/grub/grub.cfg
fi
