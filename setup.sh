#!/usr/bin/env bash


# This setup script will install all the necessary dependencies for the tool to run
# Feel free to modify it to suit your needs

########################################################
# AutoM8 - Ubuntu Post-Install Automation Tool         #
# Author: Marcio Moreira junior                        #
# email: iam@marciomoreirajunior.com.br                #
# Version 1.0                                          #
########################################################

# AutoM8 Variables
DISTRO=$(lsb_release -si 2>/dev/null)
RELEASE=$(lsb_release -sr 2>/dev/null)
CODENAME=$(lsb_release -sc 2>/dev/null)
LOGFILE="autom8.log"
HOSTNAME=$(hostname)
USER=$(whoami)

# AutoM8 Functions

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

}

check_user() {
    # Check if the script is running as root
    if [ "$EUID" == 0 ]; then
        echo "Please, do not run this script as root."
        exit
    fi
}

check_env() {
    # Check if the script was already run
    if [ -f $LOGFILE ]; then
        echo "AutoM8 was already installed. Just run autom8.sh"
        exit
    else
        touch $LOGFILE
    fi

    # Check if the distribution and release are compatible with AutoM8, which was developed on Ubuntu 24.04.
    if [ "$DISTRO" != "Ubuntu" ] || [[ $(echo "$RELEASE != 24.04" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        echo "Sorry, AutoM8 only supports Ubuntu 24.04."
        exit
    else
        echo "AutoM8 Installation Log" >> $LOGFILE
        echo "------------------------------------" >> $LOGFILE
        echo "Install Date: $(date)" >> $LOGFILE
        echo "Distribution: $DISTRO" >> $LOGFILE
        echo "Release: $RELEASE" >> $LOGFILE
        echo "Codename: $CODENAME" >> $LOGFILE
        echo "Username: $USER" >> $LOGFILE
        echo "Hostname: $HOSTNAME" >> $LOGFILE
        echo "------------------------------------" >> $LOGFILE
    fi
}

check_conn() {
    # Check internet connection
    echo "Checking Internet connection."
    if ! ping -c 3 google.com ; then
        echo "You are offline, please check your internet connection."
        exit
    fi
}

update_os() {
    echo "AutoM8 will update repositories and installed packages."
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    echo "System Updated"
    echo "OS Last Update: $(date)" >> $LOGFILE
    sleep 1
}

install_basic() {
    echo "Installing Basic Packages."
    sudo apt install -y vim net-tools git jq links rsync curl gpg wget ntpdate openssh-server tmux dconf-cli dconf-editor linux-tools-generic sshpass rar unrar bzip2 tar unzip zfsutils-linux samba-common-bin ntfs-3g libfuse2t64 neofetch figlet 
    echo "Done"
    echo "Basic Packages Installed"
    echo "Basic Packages Install: $(date)" >> $LOGFILE
    sleep 1
}

install_pack_manager() {
    echo "Installing Package Managers."
    sudo apt install -y gnome-software-plugin-flatpak flatpak synaptic snapd 
    echo "Done"
    echo "Package Managers Installed"
    echo "Package Managers Install: $(date)" >> $LOGFILE
    sleep 1
}

add_extra_repo() {
    echo "Adding Extra Repositories."
    echo "-- Hashicorp"
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $CODENAME main" | sudo tee /etc/apt/sources.list.d/hashicorp.list 
    echo "Done"

    echo "-- Docker"
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list 
    echo "Done"

    echo "-- Microsoft"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
    echo "Done"

    echo "-- Updating New Repositories"
    sudo apt update
    echo "Extra Repositories Added"
    echo "Extra Repositories: $(date)" >> $LOGFILE
    sleep 1
}

install_browsers() {
    echo "Installing Browsers."
    echo "-- Install Google Chrome"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt install -y gnome-chrome-shell
    rm google-chrome-stable_current_amd64.deb
    echo "Done"

    echo "-- Install Microsoft Edge"
    sudo apt install -y microsoft-edge-stable
    echo "Done"

    echo "Browsers Installed"
    echo "Browsers Install: $(date)" >> $LOGFILE
    sleep 1
}

install_addons_fonts() {
    echo "Installing Addons and Fonts"
    sudo apt install -y gnome-shell-extension-manager gnome-shell-extension-prefs gnome-software ubuntu-restricted-extras gnome-shell-extension-ubuntu-tiling-assistant gnome-backgrounds gnome-tweaks fonts-firacode fonts-roboto fonts-cascadia-code
    echo "Done"

    echo "-- Installing Gnome Extensions"
    extensions=( https://extensions.gnome.org/extension/4269/alphabetical-app-grid/
            https://extensions.gnome.org/extension/517/caffeine/
            https://extensions.gnome.org/extension/779/clipboard-indicator/
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

    echo "Done"
    echo "Addons Extensions and Fonts Installed"
    echo "Addons Extensions and Fonts Install: $(date)" >> $LOGFILE
    sleep 1
}

install_sysadmin() {
    echo "Installing System Administrator Tools"
    sudo apt install -y iproute2 ethtool nmap zenmap tcpdump wireshark tshark netcat-traditional traceroute iptraf-ng iftop iotop htop sysstat lsof strace pcp mtr
    echo "Done"
    echo "System Administrator Tools Installed"
    echo "System Administrator Tools Install: $(date)" >> $LOGFILE
    sleep 1
}

install_dev_tools() {
    echo "Installing Development Tools (System)"
    sudo apt install -y apt-transport-https ca-certificates software-properties-common golang gcc make git ruby python3 python3-pip python3.12-venv build-essential libglib2.0-dev-bin pkg-config linux-headers-"$(uname -r)" linux-headers-generic libssl-dev nodejs npm yarn
    echo "Done"

    echo "Installing Code editors and Automation tools"
    echo "-- Installing VSCode"
    sudo apt install -y code
    echo "Done"

    echo "-- Installing Ansible and Terraform"
    sudo apt install -y ansible ansible-lint terraform
    echo "Done"

    echo "-- Installing Android Studio and Sublime Text"
    sudo snap install android-studio --classic
    sudo snap install sublime-text --classic
    echo "Done"

    echo "Development Tools Installed"
    echo "Development Tools Install: $(date)" >> $LOGFILE
    sleep 1
}

install_virtual() {
    echo "Installing Container and Virtualization Tools"
    echo "-- Installing VirtualBox"
    sudo apt install -y virtualbox virtualbox-ext-pack virtualbox-dkms virtualbox-guest-utils virtualbox-guest-additions-iso virtualbox-guest-x11
    echo "Done"

    echo "-- Installing LXD"
    sudo snap install lxd
    echo "Done"

    echo "-- Installing Docker"
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    echo "Enabling Docker"
    sudo systemctl enable docker
    echo "Done"

    echo "-- Installing Vagrant and Packer"
    sudo apt install -y vagrant packer
    echo "Done"


    echo "Virtualization Tools Installed"
    echo "Virtualization Tools Install: $(date)" >> $LOGFILE
    sleep 1
}

install_deskapps() {
    echo "Installing Desktop Applications"
    echo "-- VLC, Gimp, Inkscape"
    sudo apt install -y vlc gimp inkscape
    echo "Done"

    echo "Spotify, Wonderwall, Kubectl, Joplin"
    sudo snap install spotify --classic
    sudo snap install wonderwall --classic
    sudo snap install kubectl --classic
    sudo snap install joplin-desktop --classic
    echo "Done"

    echo "Desktop Applications Installed"
    echo "Desktop Applications Install: $(date)" >> $LOGFILE
    sleep 1
}

home_configure() {
    echo "Configuring Home Directory"
    echo "-- Creating Development Directories"
    mkdir -p ~/OSLabs/{Personal,HOMELAB,Codes}
    echo "Done"

    echo "-- Configuring VIM as Default Editor"
    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim.basic 1
    sudo update-alternatives --set editor /usr/bin/vim.basic
    echo "Done"

    echo "-- Creating Python link"
    sudo ln -s /usr/bin/python3 /usr/bin/python
    echo "Done"

    echo "-- Enabling mouse on gnome"
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
    echo "Done"

    echo "Home Config done"
    echo "Last Home Config: $(date)" >> $LOGFILE
    sleep 1
    exit
}
    print_banner
    check_user
    check_conn
    check_env
    update_os
    install_basic
    install_pack_manager
    add_extra_repo
    install_browsers
    install_addons_fonts
    install_sysadmin
    install_dev_tools
    install_virtual
    install_deskapps
    home_configure
