#!/usr/bin/env bash

########################################################
# AutoM8 - Ubuntu Linux Setup Tool                     #
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
LOG_FILE="$INSTALL_DIR/logs/AutoM8.log"

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

checkEnvironment() {
    # Check if running the tool as root.
    echo -e "${LIGHTGREEN}AutoM8 is Checking environment...${NC}"

    if [ "EUID" == 0 ]; then
        echo -e "${RED}Running AutoM8 as Root, please use your own user. Exiting...${NC}"
        exit 1
    fi

    # Check if AutoM8 is already installed
    if [ -f $INSTALL_DIR/$LOG_FILE ]; then
        echo -e "${RED}AutoM8 is already installed. Exiting...${NC}"
        exit 1
    fi

    # Check if the system is Ubuntu Noble
    if [ "$DISTRO" != "Ubuntu" ] || [[ $(echo "$RELEASE != 24.04" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        echo -e "${RED}AutoM8 only works on Ubuntu 24.04. Exiting...${NC}"
        exit 1
    fi

    # Check Internet Connection
    if ! ping -c 3 google.com &>/dev/null; then
        echo -e "${RED}No Internet Connection. Exiting...${NC}"
        exit 1
    fi
}

installPrerequisites() {
    echo -e "${LIGHTGREEN}AutoM8 is Installing Prerequisites...${NC}"

    sudo apt update -y
    sudo apt install -y vim curl wget git unzip zip jq
}