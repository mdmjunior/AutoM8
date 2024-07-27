#!/bin/bash

########################################################
# AutoM8 - Ubuntu Install Automation Tool              #
# Author: Marcio Moreira junior                        #
########################################################

#!/bin/bash

check_env() {
    # Verificar a distribuição e release
    DISTRO=$(lsb_release -is 2>/dev/null)
    RELEASE=$(lsb_release -rs 2>/dev/null)
    USERNM=$(whoami)

    echo "[ ----------------------------------------------------- ]"
    echo " "
    echo "   █████╗ ██╗   ██╗████████╗ ██████╗ ███╗   ███╗ █████╗ "
    echo "  ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗████╗ ████║██╔══██╗"
    echo "  ███████║██║   ██║   ██║   ██║   ██║██╔████╔██║╚█████╔╝"
    echo "  ██╔══██║██║   ██║   ██║   ██║   ██║██║╚██╔╝██║██╔══██╗"
    echo "  ██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║ ╚═╝ ██║╚█████╔╝"
    echo "  ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ╚═╝ ╚════╝ "
    echo "[ ----------------------------------------------------- ]"
    echo " Ubuntu Installation Tool "


    if [ "$DISTRO" != "Ubuntu" ]; then
        echo "Distribuição não suportada: $DISTRO"
        exit 1
    fi

    if [[ $(echo "$RELEASE 20.04" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        echo "Versão do Ubuntu não suportada: $RELEASE"
        exit 1
    fi

    sleep 2
    clear

    # Perguntar se o usuário vai instalar um desktop ou server
    read -p "Você vai instalar um desktop ou server? (desktop/server): " INSTALL_TYPE

    if [ "$INSTALL_TYPE" == "desktop" ]; then
        install_desktop
    elif [ "$INSTALL_TYPE" == "server" ]; then
        install_server
    else
        echo "Tipo de instalação inválido: $INSTALL_TYPE"
        exit 1
    fi
}

install_desktop() {
    echo "Iniciando instalação otimizada para Desktop"
    echo "O script irá preparar o seu sistema operacional, aguarde..."
    echo "Distro: $DISTRO"
    echo "Release: $RELEASE"
    echo "Usuario: $USERNM"
    sleep 1
    clear

    # Atualiza os repositórios e o sistema operacional
    if [ "$USERNM" == "root" ]; then
        echo "Esse script deve ser executado com o seu usuario, $USERNM"
        exit 1
    else
        echo "Atualizando os repositórios e pacotes do SO"
        echo "Seu usuário não é root, digite a senha para elevação"
        sudo apt update && sudo apt upgrade -y
        echo "Atualização do sistema operacional finalizada!"
    fi
    sleep 1
    clear
    echo "Instalando pacotes básicos"
    sudo apt install -y ntpdate zfsutils-linux tcpdump vim nmap net-tools iptables iptables-persistent git curl wget links ruby python3 python3-pip build-essential openssl traceroute pkg-config gcc make iptraf netcat-traditional zsh iperf htop iotop
    echo "Pacotes instalados."

    sleep 1
    clear
    echo "Instalando ferramentas gráficas"
    sudo apt install -y gnome-shell-extension-manager gnome-software gnome-software-plugin-flatpak flatpak ubuntu-restricted-extras gnome-shell-extension-ubuntu-tiling-assistant gnome-extensions gnome-weather gnome-clocks gnome-tweaks fonts-firacode fonts-roboto fonts-cascadia-code chrome-gnome-shell
    echo "Pacotes instalados"

    sleep 1
    clear
    echo "Instalando utilitários e ferramentas de desktop"
    sudo apt install -y rar unrar p7zip-full p7zip-rar tlp 
    echo "Pacotes Instalados"

    sleep 1
    clear
    echo "Instalando ferramentas de trabalho"
    sudo apt install -y virtualbox ansible wireshark tshark gcc make tmux multitail timeshift openssh-server""
    echo "Pacotes Instalados"

    sleep 1
    clear
    echo "Atualizando editor de texto"
    update-alternatives --config-editor

}

install_server() {
    echo "Função de instalação do servidor"
    # Adicione aqui os comandos para instalar o servidor
}

# Chamar a função check_env
check_env
