#!/bin/bash

########################################################
# AutoM8 - Ubuntu Post-Install Automation Tool         #
# Author: Marcio Moreira junior                        #
# email: mdmjunior@gmail.com                           #
# Version 1.0                                          #
########################################################

# AutoM8 Variables
ATM_HOME="/opt/AutoM8/"
DISTRO=$(lsb_release -is 2>/dev/null)
RELEASE=$(lsb_release -rs 2>/dev/null)

first_run() {
    # This function will check if the environment is ok to run AutoM8 or else if the tool was already ran on the system.
    echo "AutoM8 will perform an environment check, please wait..."
    sleep 1
    clear

    # Checking distro and release, at this time, AutoM8 only works with Ubuntu 24.04
    if [ "$DISTRO" != "Ubuntu" ] || [[ $(echo"$RELEASE 24.04" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        echo "Distribution: $DISTRO"
        echo "Release: $RELEASE"
        echo "AutoM8 only support Ubuntu 24.04. Sorry!"
        exit 1
    fi

    # Checking if AutoM8 is installed, if not, will perform it
    echo "Checking if AutoM8 is already installed..."
    if [ -d "$ATM_HOME" ]; then
        echo "AutoM8 is installed, please run $ATM_HOME/autom8.sh --help to use the tool"
        exit 1
    else
        echo "AutoM8 is not installed, it will be performed now!"
        echo "Updating Ubuntu repository and upgrading the current installed packages: "
        sudo apt update && sudo apt upgrade -y > /dev/null 2>&1;
        echo "Operating system packages updated to the latest available version!"
        sleep 2
        clear
        echo "Installing basic packages needed for AutoM8: "
        sudo apt install -y git wget curl gcc make python3 python3-pip linux-headers-"$(uname -r)" linux-headers-generic build-essential ntpdate vim net-tools links rar unrar unzip
        echo "Basic packages installed"
        sleep 2
        clear
        echo "Downloading AutoM8: "
        git clone https://github.com/mdmjunior/AutoM8.git
        mv AutoM8/ /opt/
        chmod +x $ATM_HOME/autom8.sh
        echo "AutoM8 Installed. Run $ATM_HOME/autom8.sh --help to use the tool"
        exit 1
    fi
}