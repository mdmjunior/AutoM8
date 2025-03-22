#!/usr/bin/env bash

########################################################
# AutoM8 - Linux Ubuntu Setup Tool                     #
# Author: Marcio Moreira junior                        #
# email: iam@marciomoreirajunior.com.br                #
# Version 1.0                                          #
########################################################

# ------------------------------------------------------
# AutoM8 Variables
# ------------------------------------------------------
DISTRO=$(lsb_release -si 2>/dev/null)
CODENAME=$(lsb_release -sc 2>/dev/null)
RELEASE=$(lsb_release -sr 2>/dev/null)
ARCH=$(uname -m)
USER=$(whoami)
HOME=$(eval echo ~$USER)
INSTALL_DIR="/opt/AutoM8"
APPS_DIR="$INSTALL_DIR/apps"
LOG_DIR="$INSTALL_DIR/log"
LOG_FILE="$INSTALL_DIR/$LOG_DIR/autom8.log"
LOG_INSTALL="$INSTALL_DIR/$LOG_DIR/install.log"
LOG_APPS="$INSTALL_DIR/$LOG_DIR/apps.log"
DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------
# Colors
# ------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
WHITE='\033[0;37m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
LIGHTYELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
WHITEBOLD='\033[1;37m'
NC='\033[0m' # No Color

export RED GREEN YELLOW BLUE WHITE LIGHTRED LIGHTGREEN LIGHTYELLOW LIGHTBLUE WHITEBOLD NC

# ------------------------------------------------------
# AutoM8 Functions
# ------------------------------------------------------

printBanner() {
    echo -e ${LIGHTGREEN}
    echo "======================================================="
    echo "                                                       "
    echo "  █████╗ ██╗   ██╗████████╗ ██████╗ ███╗   ███╗ █████╗ "
    echo " ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗████╗ ████║██╔══██╗"
    echo " ███████║██║   ██║   ██║   ██║   ██║██╔████╔██║╚█████╔╝"
    echo " ██╔══██║██║   ██║   ██║   ██║   ██║██║╚██╔╝██║██╔══██╗"
    echo " ██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║ ╚═╝ ██║╚█████╔╝"
    echo " ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ╚═╝ ╚════╝ "
    echo "                                                       "
    echo "               Ubuntu Linux Setup Tool                 "
    echo "======================================================="
    echo -e ${NC}
}

createLog() {
    sudo touch $LOG_FILE
    sudo touch $LOG_INSTALL
    sudo touch $LOG_APPS
    sudo chown -R $USER:$USER $INSTALL_DIR
}

installLog() {
    echo "AutoM8 Installation Log" >> $LOG_FILE
    echo "------------------------------------" >> $LOG_FILE
    echo "Install Date: $(date)" >> $LOG_FILE
    echo "Distribution: $DISTRO" >> $LOG_FILE
    echo "Release: $RELEASE" >> $LOG_FILE
    echo "Codename: $CODENAME" >> $LOG_FILE
    echo "Username: $USER" >> $LOG_FILE
    echo "------------------------------------" >> $LOG_FILE
}

checkUser() {
    # Check if running the tool as root.
    echo -e "${LIGHTGREEN}AutoM8 is Checking environment...${NC}"
    echo -e ${NC}
    if [ "$(id -u)" == 0 ]; then
        echo -e "${RED}Running AutoM8 as Root, please use your own user. Exiting...${NC}"
        exit 1
    fi
}

checkPing() {
    # Check Internet Connection
    if ! ping -c 3 google.com &> /dev/null; then
        echo -e "${RED}No Internet Connection. Exiting...${NC}"
        exit 1
    fi
}

checkDistro() {
    # Check if the system is Ubuntu Noble
    if [ "$DISTRO" != "Ubuntu" ] || [[ $(echo "$RELEASE != 24.04" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        echo -e "${RED}AutoM8 only works on Ubuntu 24.04. Exiting...${NC}"
        exit 1
    fi
}

checkInstall() {
    # Check if AutoM8 is already installed
    if [ -f $LOG_INSTALL ]; then
        echo -e "${RED}AutoM8 is already installed. Exiting...${NC}"
        exit 1
    fi
}

main() {
    clear
    printBanner
    sleep 1
    checkUser
    checkPing
    checkDistro
    checkInstall

    # Install prerequisites and create AutoM8 Structure
    echo -e "${LIGHTGREEN}AutoM8 will now update the current repositories and installed packages.${NC}"
    echo -e "${LIGHTGREEN}This may take a while, please wait...${NC}"
    sudo apt update -y &> /dev/null && sudo apt upgrade -y &> /dev/null
    echo -e "${LIGHTGREEN}Operating System updated.${NC}"
    sleep 1

    echo -e "${LIGHTGREEN}Installing prerequisites...${NC}"
    sudo apt install -y bzip2 git curl wget unzip net-tools gcc make perl python3 python3-pip openssh-server rsync zip vim tar &> /dev/null
    echo -e "${LIGHTGREEN}Prerequisites installed.${NC}"
    sleep 1

    echo -e "${LIGHTGREEN}Installing AutoM8...${NC}"
    echo -e "${LIGHTGREEN}AutoM8 will be installed on $INSTALL_DIR ${NC}"
    git clone https://github.com/mdmjunior/AutoM8.git --depth=1 &> /dev/null && cd AutoM8

    # Creating Directories
    sudo mkdir -p $INSTALL_DIR
    sudo mkdir -p $INSTALL_DIR/$LOG_DIR
    sudo chown -R $USER:$USER $INSTALL_DIR
    sleep 1
    mv * $INSTALL_DIR/
    sudo chmod +x $INSTALL_DIR/bin/*

    # Creating Log Files
    createLog
    installLog

    echo -e "${LIGHTGREEN}AutoM8 installed. Just run $INSTALL_DIR/bin/autom8.sh ${NC}"
    sleep 1
    exit 0
}

main