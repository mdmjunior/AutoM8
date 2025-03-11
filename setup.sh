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
    if ! ping -c 3 google.com &> /dev/null; then
        echo "You are offline, please check your internet connection."
        exit
    fi
}

update_os() {
    echo "AutoM8 will update repositories and installed packages."
    sudo apt update &> /dev/null
    sudo apt upgrade -y &> /dev/null
    sudo apt autoremove -y &> /dev/null
    echo "System Updated"
    echo "OS Last Update: $(date)" >> $LOGFILE
    sleep 1
    clear
}

install_basic() {
    echo "Installing Basic Packages."
    sudo apt install -y vim net-tools git links rsync curl gpg wget ntpdate openssh-server tmux dconf-cli dconf-editor linux-tools-generic sshpass rar unrar bzip2 tar unzip zfsutils-linux samba-common-bin ntfs-3g libfuse2t64 neofetch figlet &> /dev/null
    echo "Basic Packages Installed"
    echo "Basic Install: $(date)" >> $LOGFILE
    sleep 1
    clear
}

install_pack_manager() {
    echo "Installing Package Managers."
    sudo apt install -y gnome-software-plugin-flatpak flatpak synaptic snapd &> /dev/null
    echo "Package Managers Installed"
    echo "Package Managers Install: $(date)" >> $LOGFILE
    sleep 1
    clear
}

add_extra_repo() {
    echo "Adding Extra Repositories."
    echo "Hashicorp"
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg &> /dev/null
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $CODENAME main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    echo "Done"

    echo "Docker"
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc &> /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list
    echo "Done"

    echo "Flatpak"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "Done"

    echo "Sublime Text"
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    echo "Done"

    echo "Microsoft (VScode and Edge)"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg > /dev/null
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" |sudo tee /etc/apt/sources.list.d/microsoft-edge.list
    echo "Done"

    echo "Updating New Repositories"
    sudo apt update &> /dev/null
    echo "Extra Repositories Added"
    echo "Extra Repositories: $(date)" >> $LOGFILE
    sleep 1
    clear
}

install_browsers() {
    echo "Installing Browsers."

    echo "Install Google Chrome"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &> /dev/null
    sudo dpkg -i google-chrome-stable_current_amd64.deb &> /dev/null
    sudo apt install -y gnome-chrome-shell &> /dev/null
    rm google-chrome-stable_current_amd64.deb
    echo "Done"

    echo "Install Microsoft Edge"
    sudo apt install -y microsoft-edge-stable &> /dev/null
    echo "Done"

    echo "Browsers Installed"
    echo "Browsers Install: $(date)" >> $LOGFILE
    sleep 1
    clear
}

install_addons_fonts() {
    echo "Installing Addons and Fonts"
    sudo apt install -y gnome-shell-extension-manager gnome-software ubuntu-restricted-extras gnome-shell-extension-ubuntu-tiling-assistant gnome-backgrounds gnome-tweaks fonts-firacode fonts-roboto fonts-cascadia-code
    echo "Done"

    echo "Installing Gnome Extensions"
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

    echo "Done"
    echo "Addons Extensions and Fonts Installed"
    echo "Addons Extensions and Fonts Install: $(date)" >> $LOGFILE
    sleep 1
    clear
}

install_sysadmin() {
    echo "Installing System Administrator Tools"
    sudo apt install -y iproute2 ethtool nmap zenmap tcpdump wireshark tshark netcat-traditional traceroute iperf3 iptraf-ng iftop iotop htop sysstat lsof strace pcp mtr &> /dev/null
    echo "Done"
    echo "System Administrator Tools Installed"
    echo "System Administrator Tools Install: $(date)" >> $LOGFILE
    sleep 1
    clear
}

install_dev_tools() {
    echo "Installing Development Tools (System)"
    sudo apt install -y apt-transport-https ca-certificates software-properties-common golang gcc make git ruby python3 python3-pip python3.12-venv build-essential libglib2.0-dev-bin pkg-config linux-headers-"$(uname -r)" linux-headers-generic libssl-dev nodejs npm yarn &> /dev/null
    echo "Done"

    echo "Installing My Dev Tools"
    sudo apt install -y code sublime-text ansible ansible-lint terraform &> /dev/null
    sudo snap install android-studio --classic &> /dev/null
    echo "Done"
    echo "Development Tools Installed"
    echo "Development Tools Install: $(date)" >> $LOGFILE
    sleep 1
    clear
}

install_virtual() {
    echo "Installing Container and Virtualization Tools"
    echo "Installing VirtualBox"
    sudo apt install -y virtualbox virtualbox-ext-pack virtualbox-dkms virtualbox-guest-utils virtualbox-guest-additions-iso virtualbox-guest-x11 &> /dev/null
    echo "Done"

    echo "Installing LXD"
    sudo snap install lxd
    echo "Done"

    echo "Installing Docker"
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &> /dev/null
    sudo usermod -aG docker $USER
    echo "Enabling Docker"
    sudo systemctl enable docker
    echo "Done"

    echo "Installing Vagrant and Packer"
    sudo apt install -y vagrant packer &> /dev/null
    echo "Done"


    echo "Virtualization Tools Installed"
    echo "Virtualization Tools Install: $(date)" >> $LOGFILE
    sleep 1
    clear
}

install_deskapps() {
    echo "Installing Desktop Applications"
    echo "VLC, Gimp, Inkscape"
    sudo apt install -y vlc gimp inkscape &> /dev/null
    echo "Spotfy, Wonderwall, Kubectl, Joplin"
    sudo snap install spotify --classic &> /dev/null
    sudo snap install wonderwall --classic &> /dev/null
    sudo snap install kubectl --classic &> /dev/null
    sudo snap install joplin-desktop --classic &> /dev/null
    echo "Done"
    echo "Desktop Applications Installed"
    echo "Desktop Applications Install: $(date)" >> $LOGFILE
    sleep 1
    clear
}

home_configure() {
    echo "Configuring Home Directory"
    echo "Creating Development Directories"
    mkdir -p ~/OSLabs/{Personal,HOMELAB,Codes}
    echo "Done"

    echo "Configuring VIM as Default Editor"
    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim.basic 1
    sudo update-alternatives --set editor /usr/bin/vim.basic
    echo "Done"

    echo "Creating Python link"
    sudo ln -s /usr/bin/python3 /usr/bin/python
    echo "Done"

    echo "ENABLING MOUSE CLICK ON GNOME"
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
    echo "Done"

    echo "Home Config done"
    echo "Last Home Config: $(date)" >> $LOGFILE
    sleep 1
    clear
}


main() {
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
    exit
}