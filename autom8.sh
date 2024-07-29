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

    echo "Adicionando repositórios extras"
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    echo "Repositórios Instalados"

    sleep 1
    clear
    echo "Instalando pacotes básicos"
    sudo apt install -y ntpdate vim net-tools curl wget links htop iotop openssh-server openssl tmux multitail zsh
    echo "Pacotes instalados."

    sleep 1
    clear
    echo "Instalando ferramentas de compactação de arquivos"
    sudo apt install -y rar unrar p7zip-full p7zip-rar tlp bzip2 tar unzip
    echo "Pacotes instalados"

    sleep 1
    clear
    echo "Instalando ferramentas para manipulaçao de filesystems"
    sudo apt install -y zfsutils-linux samba-common-bin ntfs-3g
    echo "Pacotes Instalados"

    sleep 1
    clear
    echo "Instalando ferramentas de rede"
    sudo apt install -y tcpdump nmap zenmap iptables iptables-persistent traceroute iptraf netcat-traditional wireshark tshark iperf
    echo "Pacotes Instalados"

    sleep 1
    clear
    echo "Instalando ferramenta de backup"
    sudo apt install -y timeshift
    echo "Pacote Instalado"

    sleep 1
    clear
    echo "Instalando add-ons do Gnome e fontes"
    sudo apt install -y gnome-shell-extension-manager gnome-software ubuntu-restricted-extras gnome-shell-extension-ubuntu-tiling-assistant gnome-extensions gnome-weather gnome-clocks gnome-tweaks fonts-firacode fonts-roboto fonts-cascadia-code chrome-gnome-shell
    echo "Pacotes instalados"

    sleep 1
    clear
    echo "Instalando gerenciadores de pacotes"
    sudo apt install -y nala gnome-software-plugin-flatpak flatpak gdebi snapd
    echo "Pacotes instalados"

    sleep 1
    clear
    echo "Instalando ferramentas de virtualização"
    sudo apt install -y virtualbox virtualbox-ext-pack virtualbox-dkms virtualbox-guest-utils virtualbox-guest-additions-iso
    echo "Pacotes instalados"

    sleep 1
    clear
    echo "Instalando ferramentas de desenvolvimento"
    sudo apt install -y apt-transport-https ca-certificates software-properties-common gcc make git ruby python3 python3-pip build-essential openssl pkg-config linux-headers-$(uname -r) linux-headers-generic libssl-dev
    echo "Pacotes instalados"

    sleep 1
    clear
    echo "Instalando ferramentas de automação"
    sudo apt install -y ansible ansible-lint terraform packer vagrant
    echo "Pacotes instalados"

    sleep 1
    clear
    echo "Instalando Google Chrome"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    dpkg -i google-chrome-stable_current_amd64.deb
    echo "Pacote instalado"

    # Instalação de pacotes via Snap

    PACOTES_SNAP=(
        code
        drawio
        firefox
        gedit
        go
        joplin-desktop
        journey
        lxd
        neofetch-desktop
        smart-file-renamer
        spotify
        sublime-text
        todoist
        wonderwall
        gnome-system-monitor
        gnome-logs
        cheese
    )

    for nome_do_programa in ${PACOTES_SNAP[@]}; do
        if ! snap list | grep $nome_do_programa; then # Só instala se já não estiver instalado
             sudo snap install "$nome_do_programa" -y
        else
            echo "[INSTALADO] - $nome_do_programa"
        fi
    done

    sleep 1
    clear
    echo "Atualizando editor de texto"
    sudo update-alternatives --set editor /usr/bin/vim
    echo "Criando Link para o Python"
    sudo ln -s /usr/bin/python3 /usr/bin/python

}

install_server() {
    echo "Função de instalação do servidor"
    # Adicione aqui os comandos para instalar o servidor
}

# Chamar a função check_env
check_env
