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

    echo "  [ -------------------------------------------------- ]"
    echo "                                                        "
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
    sudo systemctl daemon-reload
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
    sudo apt install -y ntpdate vim net-tools iproute2 curl wget links htop iotop openssh-server openssl tmux multitail zsh sshpass expect gpg dconf-cli dconf-editor
    echo "Pacotes instalados."

    sleep 1
    echo "ADICIONANDO REPOSITÓRIOS EXTRAS"
    echo "INSTALANDO REPOSITORIO HASHICORP"
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
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
    sudo apt install -y rar unrar p7zip-full p7zip-rar tlp tlp-rdw bzip2 tar unzip smartmontools linux-tools-generic 7zip-standalone
    sudo systemctl enable tlp
    echo "Pacotes instalados"

    sleep 1
    echo "INSTALANDO FERRAMENTAS PARA MANIPULAÇAO DE FILESYSTEMS"
    sudo apt install -y zfsutils-linux samba-common-bin ntfs-3g libfuse2t64
    echo "Pacotes Instalados"

    sleep 1
    echo "INSTALANDO FERRAMENTAS DE REDE"
    sudo apt install -y tcpdump nmap zenmap iptables iptables-persistent traceroute iptraf-ng netcat-traditional wireshark tshark iperf geoipupdate geoip-database
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
    sudo apt install -y gnome-shell-extension-manager gnome-software ubuntu-restricted-extras gnome-shell-extension-ubuntu-tiling-assistant gnome-backgrounds gnome-weather gnome-clocks gnome-tweaks fonts-firacode fonts-roboto fonts-cascadia-code chrome-gnome-shell
    echo "Pacotes instalados"

    sleep 1 
    echo "Instalando Extensões do Gnome"
    extensions=( https://extensions.gnome.org/extension/4269/alphabetical-app-grid/
            https://extensions.gnome.org/extension/6682/astra-monitor/
            https://extensions.gnome.org/extension/3193/blur-my-shell/
            https://extensions.gnome.org/extension/517/caffeine/
            https://extensions.gnome.org/extension/779/clipboard-indicator/
            https://extensions.gnome.org/extension/2087/desktop-icons-ng-ding/
            https://extensions.gnome.org/extension/1319/gsconnect/
            https://extensions.gnome.org/extension/1301/ubuntu-appindicators/
            https://extensions.gnome.org/extension/1300/ubuntu-dock/
            https://extensions.gnome.org/extension/19/user-themes/
            https://extensions.gnome.org/extension/21/workspace-indicator/ )

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
    echo "Extensões instaladas"

    sleep 1
    echo "INSTALANDO FERRAMENTAS DE VIRTUALIZAÇÃO"
    sudo apt install -y virtualbox virtualbox-ext-pack virtualbox-dkms virtualbox-guest-utils virtualbox-guest-additions-iso virtualbox-guest-x11
    echo "Pacotes instalados"

    sleep 1
    echo "INSTALANDO FERRAMENTAS DE DESENVOLVIMENTO"
    sudo apt install -y apt-transport-https ca-certificates software-properties-common gcc make git ruby python3 python3-pip python3.12-venv build-essential libglib2.0-dev-bin openssl pkg-config linux-headers-"$(uname -r)" linux-headers-generic libssl-dev
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
    sudo snap install gedit
    sudo snap install go --classic
    sudo snap install joplin-desktop
    sudo snap install lxd
    sudo snap install neofetch-desktop
    sudo snap install smart-file-renamer
    sudo snap install spotify
    sudo snap install sublime-text --classic
    sudo snap install wonderwallMarcio
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
    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim.basic 1
    sudo update-alternatives --set editor /usr/bin/vim.basic

    echo "CRIANDO LINK PARA O PYTHON"
    sudo ln -s /usr/bin/python3 /usr/bin/python

    echo "ADICIONANDO USUARIO AO GRUPO DO VBOX"
    sudo usermod -aG vboxusers mmoreira

    echo "HABILITANDO MINIMIZAR NO CLICK DO MOUSE"
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

    echo "Configurando git para o usuário $USERNM"
    echo "Digite o Nome completo do usuário $USERNM"
    read -r GIT_REALNAME
    echo "Digite o email do usuario $USERNM"
    read -r GIT_EMAIL
    git config --global user.name "$GIT_REALNAME"
    git config --global user.email "$GIT_EMAIL"

    sleep 1
    echo "Restaurando configurações do Gnome"
    git clone https://github.com/mdmjunior/AutoM8.git
    cd AutoM8 || exit
    dconf load -f / < saved_settings.dconf

    sleep 1
    # Removendo pacotes não utilizados
    echo "REMOVENDO PACOTES DESNECESSÁRIOS"
    sudo apt remove -y --purge apport apport-gtk rhythmbox
    sudo apt autoremove -y
    sudo apt autoclean -y
    sudo systemctl daemon-reload

    sleep 1
    # Criando chave privada para o usuario
    echo "Criando Chave privada para o usuário $USERNM"
    ssh-keygen -t ed25519 -C "mdmjunior@gmail.com"
    echo "Chave criada com sucesso"

    sleep 1
    # Adicionando usuário ao sudo sem senha
    echo "Adicionando usuário ao sudoers"
    echo "%mmoreira ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

    sleep 1
    # Configurando SSH
    echo "Configurando SSH Server para permitir login com chave"
    sudo sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/g' /etc/ssh/sshd_config
    echo "Reiniciando serviço SSHD"
    sudo systemctl restart ssh

    sleep 1
    echo "SISTEMA PRONTO PARA USO"
    exit
}

install_server() {
    echo "Função de instalação do servidor ainda não implementada"
    exit 1
}

# Chamar a função check_env
check_env
