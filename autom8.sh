#!/bin/bash

########################################################
# AutoM8 - Ubuntu Post-Install Automation Tool         #
# Author: Marcio Moreira junior                        #
# email: mdmjunior@gmail.com                           #
# Versão 1.0                                           #
########################################################

check_env() {
    # Verificar a distribuição e release
    DISTRO=$(lsb_release -is 2>/dev/null)
    RELEASE=$(lsb_release -rs 2>/dev/null)
    USERNM=$(whoami)
   u
    echo "  [ -------------------------------------------------- ]"
    echo " "
    echo "   █████╗ ██╗   ██╗████████╗ ██████╗ ███╗   ███╗ █████╗ "
    echo "  ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗████╗ ████║██╔══██╗"
    echo "  ███████║██║   ██║   ██║   ██║   ██║██╔████╔██║╚█████╔╝"
    echo "  ██╔══██║██║   ██║   ██║   ██║   ██║██║╚██╔╝██║██╔══██╗"
    echo "  ██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║ ╚═╝ ██║╚█████╔╝"
    echo "  ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ╚═╝ ╚════╝ "
    echo "  [ -------------------------------------------------- ]"
    echo "              Ubuntu Post-Installation Tool             "
    echo "       https://marciomoreirajunior.com.br/AutoM8/       "

    # Verifica se a distribuição é compatível
    if [ "$DISTRO" != "Ubuntu" ]; then
        echo "Distribuição não suportada: $DISTRO"
        exit 1
    fi

    if [[ $(echo "$RELEASE 20.04" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        echo "Versão do Ubuntu não suportada: $RELEASE"
        exit 1
    fi

    sleep 2

    # Perguntar se o usuário vai instalar um desktop ou server
    echo "Você vai instalar um desktop ou server? (desktop/server): "
    read -r INSTALL_TYPE

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
    echo "INICIANDO INSTALAÇÃO OTIMIZADA PARA DESKTOP"
    echo "O script irá preparar o seu sistema operacional, aguarde..."
    echo "DISTRO: $DISTRO"
    echo "RELEASE: $RELEASE"
    echo "USUARIO: $USERNM"
    sleep 1

    # Atualiza os repositórios e o sistema operacional

    if [ "$USERNM" == "root" ]; then
        echo "Esse script deve ser executado com o seu usuario, $USERNM"
        exit 1
    else
        echo "ATUALIZANDO OS REPOSITÓRIOS E PACOTES DO SO"
        echo "Seu usuário não é root, digite a senha para elevação"
        sudo apt update && sudo apt upgrade -y
        echo "Atualização do sistema operacional finalizada!"
    fi

    sleep 1
    echo "INSTALANDO PACOTES BÁSICOS"
    sudo apt install -y ntpdate vim net-tools curl wget links htop iotop openssh-server openssl tmux multitail zsh sshpass expect gpg dconf
    echo "Pacotes instalados."

    sleep 1
    echo "ADICIONANDO REPOSITÓRIOS EXTRAS"
    echo "INSTALANDO REPOSITORIO HASHICORP"
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    echo "INSTALANDO REPOSITORIO TOR"
    wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | sudo gpg --dearmor -o /usr/share/keyrings/deb.torproject.org-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/tor.list
    sudo apt update
    echo "Repositórios Instalados"

    sleep 1
    echo "INSTALANDO GERENCIADORES DE PACOTES"
    sudo apt install -y nala gnome-software-plugin-flatpak flatpak gdebi snapd
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "OTIMIZANDO NALA"
    sudo nala fetch
    echo "Pacotes instalados"

    sleep 1
    echo "INSTALANDO FERRAMENTAS DE COMPACTAÇÃO DE ARQUIVOS"
    sudo apt install -y rar unrar p7zip-full p7zip-rar tlp tlp-rdw bzip2 tar unzip
    sudo systemctl enable tlp
    echo "Pacotes instalados"

    sleep 1
    echo "INSTALANDO FERRAMENTAS PARA MANIPULAÇAO DE FILESYSTEMS"
    sudo apt install -y zfsutils-linux samba-common-bin ntfs-3g libfuse2
    echo "Pacotes Instalados"

    sleep 1
    echo "INSTALANDO FERRAMENTAS DE REDE"
    sudo apt install -y tcpdump nmap zenmap iptables iptables-persistent traceroute iptraf netcat-traditional wireshark tshark iperf
    echo "Pacotes Instalados"

    sleep 1
    echo "INSTALANDO PACOTES DE SEGURANÇA E VPN"
    sudo apt install -y network-manager-openvpn network-manager-openvpn-gnome openvpn

    sleep 1
    echo "INSTALANDO FERRAMENTA DE BACKUP"
    sudo apt install -y timeshift
    echo "Pacote Instalado"

    sleep 1
    echo "INSTALANDO ADDONS DO GNOME E FONTES"
    sudo apt install -y gnome-shell-extension-manager gnome-software ubuntu-restricted-extras gnome-shell-extension-ubuntu-tiling-assistant gnome-weather gnome-clocks gnome-tweaks fonts-firacode fonts-roboto fonts-cascadia-code chrome-gnome-shell
    echo "Pacotes instalados"

    sleep 1
    echo "INSTALANDO FERRAMENTAS DE VIRTUALIZAÇÃO"
    sudo apt install -y virtualbox virtualbox-ext-pack virtualbox-dkms virtualbox-guest-utils virtualbox-guest-additions-iso
    echo "Pacotes instalados"

    sleep 1
    echo "INSTALANDO FERRAMENTAS DE DESENVOLVIMENTO"
    sudo apt install -y apt-transport-https ca-certificates software-properties-common gcc make git ruby python3 python3-pip build-essential openssl pkg-config linux-headers-"$(uname -r)" linux-headers-generic libssl-dev
    echo "Pacotes instalados"

    sleep 1
    echo "INSTALANDO FERRAMENTAS DE AUTOMAÇÃO"
    sudo apt install -y ansible ansible-lint terraform packer vagrant
    echo "Pacotes instalados"

    sleep 1
    echo "INSTALANDO GOOGLE CHROME"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    echo "Pacote instalado"

    # Instalação de pacotes via Snap
    echo "INSTALAÇÃO DE SOFTWARES VIA SNAP"
    sudo snap install code --classic
    sudo snap install drawio
    sudo snap install firefox
    sudo snap install gedit
    sudo snap install go --classic
    sudo snap install joplin-desktop
    sudo snap install journey
    sudo snap install lxd
    sudo snap install neofetch-desktop
    sudo snap install smart-file-renamer
    sudo snap install spotify
    sudo snap install sublime-text --classic
    sudo snap install wonderwall
    sudo snap install gnome-system-monitor
    sudo snap install gnome-logs
    sudo snap install todoist
    sudo snap install cheese
    echo "Pacotes instalados"

    sleep 1
    echo "INSTALANDO STACER"
    sudo nala install -y stacer
    echo "Stacer instalado"

    sleep 1
    echo "ATUALIZANDO EDITOR DE TEXTO"
    sudo update-alternatives --set editor /usr/bin/vim
    echo "CRIANDO LINK PARA O PYTHON"
    sudo ln -s /usr/bin/python3 /usr/bin/python
    echo "ADICIONANDO USUARIO AO GRUPO DO VBOX"
    sudo usermod -aG vboxusers mmoreira
    echo "HABILITANDO MINIMIZAR NO CLICK DO MOUSE"
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

    # Removendo pacotes não utilizados
    echo "REMOVENDO PACOTES DESNECESSÁRIOS"
    sudo apt remove -y --purge apport apport-gtk rhythmbox
    sudo apt autoremove -y
    sudo apt autoclean -y


    echo "SISTEMA PRONTO PARA USO"
    exit
}

install_server() {
    echo "Função de instalação do servidor ainda não implementada"
    exit 1
}

# Chamar a função check_env
check_env
