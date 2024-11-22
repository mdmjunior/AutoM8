#!/usr/bin/env bash

########################################################
# AutoM8 - Ubuntu Post-Install Automation Tool         #
# Author: Marcio Moreira junior                        #
# email: mdmjunior@gmail.com                           #
# Version 1.0                                          #
########################################################

# Ubuntu Post Install tool
# OS Variables
DISTRO=$(lsb_release -is 2>/dev/null)
RELEASE=$(lsb_release -rs 2>/dev/null)
VERSION_CODENAME=$(lsb_release -cs 2>/dev/null)

print_banner() {
    echo "                                                       "
    echo "  █████╗ ██╗   ██╗████████╗ ██████╗ ███╗   ███╗ █████╗ "
    echo " ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗████╗ ████║██╔══██╗"
    echo " ███████║██║   ██║   ██║   ██║   ██║██╔████╔██║╚█████╔╝"
    echo " ██╔══██║██║   ██║   ██║   ██║   ██║██║╚██╔╝██║██╔══██╗"
    echo " ██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║ ╚═╝ ██║╚█████╔╝"
    echo " ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ╚═╝ ╚════╝ "
    echo "                                                       "
    echo "           Ubuntu Post-Installation Tool               "
    echo "           https://www.oslabs.dev/autom8               "

}

check_env() {
    # Check if the distribution and release are compatible with AutoM8, which was developed on Ubuntu 24.04.
    if [ "$DISTRO" != "Ubuntu" ] || [[ $(echo "$RELEASE != 24.04" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        echo -e "\e[32mDISTRO:\e[0m $DISTRO"
        echo -e "\e[32mRELEASE:\e[0m $RELEASE"
        echo -e "\e[32mCODENAME:\e[0m $VERSION_CODENAME"
        echo "AutoM8 ONLY SUPPORTS UBUNTU VERSION 24.04. OR NEWER"
        exit
    fi

    # Check internet connection
    echo "CHECKING INTERNET CONNECTION"
    if ! ping -c 3 google.com &> /dev/null; then
        echo "INTERNET CONNECTION IS REQUIRED TO RUN AUTOM8."
        exit 1
    fi
}

check_root_user() {
    if [ "$(id -u)" != 0 ]; then
        echo 'Please run the script as root!'
        echo 'We need to do administrative tasks'
        exit
    fi
}

basic_settings() {
    DATETIMENOW=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "CURRENT DATE AND TIME: $DATETIMENOW\n"
    read -r "IS IT CORRECT? (Y/N): " confirm
    if [[ $confirm != "y" && $confirm != "Y" ]]; then
        read -r "SELECT THE CORRECT TIMEZONE: " TIMEZONE
        sudo timedatectl set-timezone "$TIMEZONE"
        echo "TIMEZONE UPDATED: $TIMEZONE"
        echo -e "\e[32mOK - DONE\e[0m"
    fi

    HOSTNAME=$(hostname)
    echo -e "CURRENT HOSTNAME: $HOSTNAME\n"
    read -r "IS IT CORRECT? (Y/N): " hostconfirm
    if [[ $hostconfirm == "n" || $hostconfirm == "N" ]]; then
        read -r "TYPE THE CORRECT HOSTNAME: " HSNAME
        sudo hostnamectl set-hostname "$HSNAME"
        echo "HOSTNAME UPDATED: $HSNAME"
        echo -e "\e[32mOK - DONE\e[0m"
    fi
}

cleanup() {
    sudo apt autoremove -y
}

install_basic_packages() {
    echo "UPDATING SYSTEM REPOSITORIES"
    sudo apt update &> /dev/null
    echo -e "\e[32mOK - DONE\e[0m"
    sleep 2
    read -r "DO YOU WANT TO SEE AVAILABLE UPDATES? (Y/N): " upgradeask
    if [[ $upgradeask == "Y" || $upgradeask == "y" ]]; then
        echo -e "UPGRADE LIST: \n"
        sudo apt list --upgradable
    fi
    echo "UPDATING INSTALLED PACKAGES"
    sudo apt upgrade -y &> /dev/null
    echo -e "\e[32mOK - DONE\e[0m"

    echo "INSTALLING BASIC PACKAGES"

    packages=(
        net-tools
        git
        nmap
        vim
        tcpdump
        gpg
        wget
        curl
        links
        ntpdate
        zfsutils-linux
        openssh-server
        iptables
        iptables-persistent
        htop
        iotop
        tmux
        dconf-cli
        dconf-editor
        linux-tools-generic
        rar
        unrar
        bzip2
        tar
        unzip
        zenmap
        ethtool
        iproute2
        traceroute
        iptraf-ng
        netcat-traditional
        wireshark
        iperf
        samba-common-bin
        ntfs-3g
        libfuse2t64
    )
    for package in "${packages[@]}"; do
        echo "INSTALLING $package..."
        sudo apt install -y "$package" > /dev/null 2>&1 &
        pid=$!
        while ps -p $pid > /dev/null; do
            echo -n "."
            sleep 1
        done
        echo -e "\e[32mOK - DONE\e[0m"
    done

    # Remove and Disable UFW
    echo "DISABLING AND REMOVING UFW"
    sudo ufw disable &> /dev/null
    sudo apt remove --purge ufw -y &> /dev/null

    # Changing default editor
    echo "CHANGING DEFAULT EDITOR TO VIM"
    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim.basic 1
    sudo update-alternatives --set editor /usr/bin/vim.basic

    # Make changes to SSHD to allow key login
    echo "MAKE CHANGES TO SSHD TO ALLOW KEY LOGIN"
    sudo sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/" /etc/ssh/sshd_config
    sudo systemctl restart ssh
}

install_pack_managers() {
    echo "INSTALLING PACKAGE MANAGERS"
    sudo apt install -y gnome-software-plugin-flatpak flatpak synaptic snapd
    echo "ADDING FLATPAK REPO"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo -e "\e[32mOK - DONE\e[0m"
}

install_backup_tools() {
    echo "INSTALLING BACKUP TOOLS"
    sudo apt install -y timeshift extundelete
    echo -e "\e[32mOK - DONE\e[0m"
}

install_addons_fonts() {
    echo "INSTALLING GNOME ADDONS AND FONTS"
    sudo apt install -y gnome-shell-extension-manager gnome-software ubuntu-restricted-extras gnome-shell-extension-ubuntu-tiling-assistant gnome-backgrounds gnome-tweaks fonts-firacode fonts-roboto fonts-cascadia-code
    echo -e "\e[32mOK - DONE\e[0m"

    echo "INSTALLING GNOME EXTENSIONS"
    extensions=( https://extensions.gnome.org/extension/4269/alphabetical-app-grid/
            https://extensions.gnome.org/extension/517/caffeine/
            https://extensions.gnome.org/extension/779/clipboard-indicator/
            https://extensions.gnome.org/extension/2087/desktop-icons-ng-ding/
            https://extensions.gnome.org/extension/1301/ubuntu-appindicators/
            https://extensions.gnome.org/extension/1300/ubuntu-dock/
            https://extensions.gnome.org/extension/19/user-themes/ )

    for i in "${extensions[@]}"
    do
        EXTENSION_ID=$(curl -s "$i" | grep -oP 'data-uuid="\K[^"]+')
        VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$EXTENSION_ID" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
        wget -O "${EXTENSION_ID}".zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
        gnome-extensions install --force "${EXTENSION_ID}".zip
        if ! gnome-extensions list | grep --quiet "${EXTENSION_ID}"; then
            busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s "${EXTENSION_ID}"
        fi
        gnome-extensions enable "${EXTENSION_ID}"
        rm "${EXTENSION_ID}".zip
    done
    echo -e "\e[32mOK - DONE\e[0m"
}

add_extra_repo() {
    echo "INSTALLING HASHICORP REPO"
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    echo -e "\e[32mOK - DONE\e[0m"
}

install_dev_tools() {
    echo "INSTALLING DEVELOPMENT TOOLS"
    sudo apt install -y apt-transport-https ca-certificates software-properties-common gcc make git ruby python3 python3-pip python3.12-venv build-essential libglib2.0-dev-bin pkg-config linux-headers-"$(uname -r)" linux-headers-generic libssl-dev
    echo -e "\e[32mOK - DONE\e[0m"

    echo "INSTALLING VIRTUALIZATION TOOLS"
    sudo apt install -y virtualbox virtualbox-ext-pack virtualbox-dkms virtualbox-guest-utils virtualbox-guest-additions-iso virtualbox-guest-x11
    echo -e "\e[32mOK - DONE\e[0m"

    echo "INSTALLING AUTOMATION TOOLS"
    sudo apt install -y ansible ansible-lint terraform packer vagrant
    echo -e "\e[32mOK - DONE\e[0m"
}

install_docker_desktop(){
    echo "INSTALLING DOCKER DESKTOP"
    wget https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
    sudo apt install ./docker-desktop-amd64.deb
    rm -rf docker-desktop-amd64.deb
    echo -e "\e[32mOK - DONE\e[0m"
}

install_vscode() {
    echo "INSTALLING VSCODE"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc |sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    sudo apt update && sudo apt install vscode -y
    echo -e "\e[32mOK - DONE\e[0m"
}

install_browsers() {
    echo "MICROSOFT EDGE"
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" |sudo tee /etc/apt/sources.list.d/microsoft-edge.list
    sudo apt update && sudo apt install microsoft-edge-stable
    echo -e "\e[32mOK - DONE\e[0m"

    echo "MOZILLA FIREFOX"
    sudo apt remove --purge firefox -y
    sudo snap remove --purge firefox
    wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/packages.mozilla.org.asc
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" |sudo tee /etc/apt/sources.list.d/mozilla.list
    echo "
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
" |sudo tee /etc/apt/preferences.d/mozilla
    sudo apt update
    sudo apt install firefox -y
    echo -e "\e[32mOK - DONE\e[0m"

    echo "GOOGLE CHROME"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt install -y chrome-gnome-shell
    rm -rf google-chrome-stable_current_amd64.deb
    echo -e "\e[32mOK - DONE\e[0m"
}

msg() {
    tput setaf 2
    echo "[*] $1"
    tput sgr0
}

error_msg() {
    tput setaf 1
    echo "[!] $1"
    tput sgr0
}

ask_reboot() {
    echo 'Reboot now? (y/n)'
    while true; do
        read -p choice
        if [[ "$choice" == 'y' || "$choice" == 'Y' ]]; then
            reboot
            exit 0
        fi
        if [[ "$choice" == 'n' || "$choice" == 'N' ]]; then
            break
        fi
    done
}

show_menu() {
    echo 'Choose what to do: '
    echo '1 - Apply everything (RECOMMENDED)'
    echo '2 - Change basic settings'
    echo '3 - Install Basic Packages'
    echo '4 - Install Package managers'
    echo '5 - Install Backup tools'
    echo '6 - Install addons and fonts'
    echo '7 - Add extra repo'
    echo '8 - Install Devel tools'
    echo '9 - Install Docker desktop'
    echo '10 - Install VSCode'
    echo '11 - Install Browsers'
    echo 'q - Exit'
    echo
}

main() {
    check_env
    check_root_user
    while true; do
        print_banner
        show_menu
        read -p 'Enter your choice: ' choice
        case $choice in
        1)
            auto
            msg 'Done!'
            ask_reboot
            ;;
        2)
            basic_settings
            msg 'Done!'
            ;;
        3)
            install_basic_packages
            msg 'Done!'
            ask_reboot
            ;;
        4)
            install_pack_managers
            msg 'Done!'
            ask_reboot
            ;;
        5)
            install_backup_tools
            msg 'Done!'
            ;;
        6)
            install_addons_fonts
            msg 'Done!'
            ask_reboot
            ;;
        7)
            add_extra_repo
            msg 'Done!'
            ;;
        8)
            install_dev_tools
            msg 'Done!'
            ask_reboot
            ;;

        9)
            install_docker_desktop
            msg 'Done!'
            ;;

        10)
            install_vscode
            msg 'Done!'
            ;;
        11)
            install_browsers
            msg 'Done!'
            ;;
        q)
            exit 0
            ;;
        *)
            error_msg 'Wrong input!'
            ;;
        esac
    done

}

auto() {
    msg 'Changing Basic settings'
    basic_settings
    msg 'Installing Basic packages'
    install_basic_packages
    msg 'Installing Package Managers'
    install_pack_managers
    msg 'Installing Backup tools'
    install_backup_tools
    msg 'Installing addons and fonts'
    install_addons_fonts
    msg 'Adding extra repo'
    add_extra_repo
    msg 'Installing Dev Tools'
    install_dev_tools
    msg 'Installing Docker Desktop'
    install_docker_desktop
    msg 'Installing VSCode'
    install_vscode
    msg 'Installing Browsers'
    install_browsers
    msg 'Cleaning up'
    cleanup
    ask_reboot
}