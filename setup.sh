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
        echo "The script was already installed. Just run autom8.sh"
        exit
    else
        touch $LOGFILE
    fi

    # Check if the distribution and release are compatible with AutoM8, which was developed on Ubuntu 24.04.
    if [ "$DISTRO" != "Ubuntu" ] || [[ $(echo "$RELEASE != 24.04" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        echo "Sorry, AutoM8 only supports Ubuntu 24.04."
        exit
    else
        echo "AutoM8 installation" > $LOGFILE
        echo "Install Date: $(date)" > $LOGFILE
        echo "Distribution: $DISTRO" > $LOGFILE
        echo "Release: $RELEASE" > $LOGFILE
        echo "Codename: $CODENAME" > $LOGFILE
        echo "Username: $USER" > $LOGFILE
        echo "Hostname: $HOSTNAME" > $LOGFILE
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
    echo "The script will update repositories and installed packages."
    sudo apt update &> /dev/null
    sudo apt upgrade -y &> /dev/null
    sudo apt autoremove -y &> /dev/null
    sleep 1
}

install_basic() {
    echo "Installing basic packages."
    sudo apt install -y vim net-tools git curl wget ntpdate openssh-server tmux dconf-cli dconf-editor linux-tools-generic sshpass rar unrar bzip2 tar unzip zfsutils-linux samba-common-bin ntfs-3g libfuse2t64 software-properties-common &> /dev/null
    echo "Installed"
    sleep 1
}

install_mine() {
    echo "Installing my desired packages."
    sudo apt install -y neofetch figlet build-essential ca-certificates apt-transport-https software-properties-common &> /dev/null
}
