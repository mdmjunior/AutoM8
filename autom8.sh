#!/bin/bash

########################################################
# AutoM8 - Ubuntu Post-Install Automation Tool         #
# Author: Marcio Moreira junior                        #
# email: mdmjunior@gmail.com                           #
# Versão 1.0                                           #
########################################################

check_env() {

    # Verifica se a distribuição e release são compatíveis com o AutoM8, que foi desenvolvido em Ubuntu 24.04.
    DISTRO=$(lsb_release -is 2>/dev/null)
    RELEASE=$(lsb_release -rs 2>/dev/null)
    # Verifica usuário atual
    USERNM=$(whoami)

    if [ "$DISTRO" != "Ubuntu" ] || [[ $(echo"$RELEASE 24.04" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        echo -e "\e[32mDISTRIBUIÇÃO:\e[0m $DISTRO"
        echo -e "\e[32mRELEASE:\e[0m $RELEASE"
        echo "No momento o AutoM8 suporta somente Ubuntu a partir da versão 24.04."
        exit 1
    fi

    clear
    echo "                                                        "
    echo "   █████╗ ██╗   ██╗████████╗ ██████╗ ███╗   ███╗ █████╗ "
    echo "  ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗████╗ ████║██╔══██╗"
    echo "  ███████║██║   ██║   ██║   ██║   ██║██╔████╔██║╚█████╔╝"
    echo "  ██╔══██║██║   ██║   ██║   ██║   ██║██║╚██╔╝██║██╔══██╗"
    echo "  ██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║ ╚═╝ ██║╚█████╔╝"
    echo "  ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ╚═╝ ╚════╝ "
    echo "                                                        "
    echo "            Ubuntu Post-Installation Tool               "

    # Verifica se o script já foi instalado, se sim, vai direto para a função recipes.
    LOG_FILE="AutoM8/logs/install.log"
    if [ -f "$LOG_FILE" ]; then
        echo "AutoM8 já executado anteriormente."
        recipes
    else
        install_autom8
    fi
}

install_autom8() {
    echo "INSTALANDO AUTOM8"
    echo "O script irá preparar o seu sistema operacional, aguarde."
    echo -e "\e[32mDISTRO:\e[0m $DISTRO"
    echo -e "\e[32mRELEASE:\e[0m $RELEASE"
    echo -e "\e[32mUSUARIO:\e[0m $USERNM"
    sudo systemctl daemon-reload

    # Atualiza os repositórios e o sistema operacional
    if [ "$USERNM" == "root" ]; then
        echo "[ERROR]: Esse script deve ser executado com o seu usuario, $USERNM"
        exit 1
    else
        echo "ATUALIZANDO OS REPOSITÓRIOS E PACOTES DO SO"
        echo "Seu usuário não tem privilégios de root, digite a senha para elevação: "
        sudo apt update && sudo apt upgrade -y
        echo -e "\e[32mAtualização do sistema operacional finalizada.\e[0m"

        echo "INSTALANDO PACOTES BÁSICOS DO SO"
        sudo apt install -y ntpdate vim net-tools curl wget links htop iotop openssh-server tmux dconf-cli dconf-editor linux-tools-generic rar unrar bzip2 tar unzip
        echo -e "\e[32mPacotes básicos instalados\e[0m"

        echo "CRIANDO DIRETÓRIOS DO AUTOM8"
        mkdir -p AutoM8/{logs,Recipes,Downloads}

        # Salvando log de execução
        echo "Instalado em " > AutoM8/logs/install.log

        install_desktop
    fi
}

install_desktop() {
    echo "INICIANDO INSTALAÇÃO PARA DESKTOP"

    echo "INSTALANDO GERENCIADORES DE PACOTES"
    sudo apt install -y gnome-software-plugin-flatpak flatpak synaptic snapd
    echo -e "\e[32mGerenciadores de pacotes instalados\e[0m"

    echo "ADICIONANDO REPOSITÓRIOS EXTRAS"
    echo "Instalando repositorio hashicorp"
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

    echo "Instalando repositorio Docker"
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "Instalando repositorio OpenVPN"
    sudo curl -fsSL https://packages.openvpn.net/packages-repo.gpg -o /etc/apt/keyrings/openvpn.asc
    echo "deb [signed-by=/etc/apt/keyrings/openvpn.asc] https://packages.openvpn.net/openvpn3/debian $VERSION_CODENAME main" >>/etc/apt/sources.list.d/openvpn3.list
    sudo apt update

    echo "Instalar repositorio Flatpak"
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    echo "INSTALANDO GOOGLE CHROME"
    cd Downloads/ || exit
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt install -y chrome-gnome-shell
    echo -e "\e[32mPacotes Instalados\e[0m"

    echo "INSTALANDO PACOTES DE FILESYSTEMS"
    sudo apt install -y zfsutils-linux samba-common-bin ntfs-3g libfuse2t64
    echo -e "\e[32mPacotes instalados\e[0m"

    echo "INSTALANDO FERRAMENTAS DE REDE"
    sudo apt install -y tcpdump nmap zenmap iptables iptables-persistent ethtool iproute2 traceroute iptraf-ng netcat-traditional wireshark iperf
    echo -e "\e[32mPacotes instalados\e[0m"

    echo "INSTALANDO PACOTES DE SEGURANÇA E VPN"
    sudo apt install -y openvpn3
    echo -e "\e[32mPacotes Instalados\e[0m"

    echo "INSTALANDO FERRAMENTA DE BACKUP"
    sudo apt install -y timeshift extundelete
    echo -e "\e[32mPacotes Instalados\e[0m"

    echo "INSTALANDO ADDONS DO GNOME E FONTES"
    sudo apt install -y gnome-shell-extension-manager gnome-software ubuntu-restricted-extras gnome-shell-extension-ubuntu-tiling-assistant gnome-backgrounds gnome-clocks gnome-tweaks fonts-firacode fonts-roboto fonts-cascadia-code
    echo -e "\e[32mPacotes Instalados\e[0m"

    echo "INSTALANDO EXTENSÕES DO GNOME"
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
    echo -e "\e[32mPacotes Instalados\e[0m"

    echo "INSTALANDO FERRAMENTAS DE DESENVOLVIMENTO"
    sudo apt install -y apt-transport-https ca-certificates software-properties-common gcc make git ruby python3 python3-pip python3.12-venv build-essential libglib2.0-dev-bin pkg-config linux-headers-"$(uname -r)" linux-headers-generic libssl-dev
    echo -e "\e[32mPacotes Instalados\e[0m"

    echo "INSTALANDO FERRAMENTAS DE VIRTUALIZAÇÃO"
    sudo apt install -y virtualbox virtualbox-ext-pack virtualbox-dkms virtualbox-guest-utils virtualbox-guest-additions-iso virtualbox-guest-x11
    echo -e "\e[32mPacotes Instalados\e[0m"

    echo "INSTALANDO FERRAMENTAS DE AUTOMAÇÃO"
    sudo apt install -y ansible ansible-lint terraform packer vagrant
    echo -e "\e[32mPacotes Instalados\e[0m"

    echo "INSTALAÇÃO DE SOFTWARES VIA SNAP"
    sudo snap install code --classic
    sudo snap install drawio
    sudo snap install gedit
    sudo snap install go --classic
    sudo snap install joplin-desktop
    sudo snap install lxd
    sudo snap install smart-file-renamer
    sudo snap install spotify
    sudo snap install sublime-text --classic
    sudo snap install wonderwall
    sudo snap install gtk-theme-orchis
    sudo snap install gtk-common-themes
    echo -e "\e[32mPacotes Snap Instalados\e[0m"

    echo "ATUALIZANDO EDITOR DE TEXTO PADRÃO"
    sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim.basic 1
    sudo update-alternatives --set editor /usr/bin/vim.basic

    echo "CRIANDO LINK PARA O PYTHON"
    sudo ln -s /usr/bin/python3 /usr/bin/python

    echo "ADICIONANDO USUARIO AO GRUPO DO VBOX"
    sudo usermod -aG vboxusers "$USERNM"

    echo "HABILITANDO MINIMIZAR NO CLICK DO MOUSE"
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

    echo "CONFIGURANDO GIT PARA O USUÁRIO $USERNM"
    echo "Digite o Nome completo do usuário $USERNM"
    read -r GIT_REALNAME
    echo "Digite o email do usuario $USERNM"
    read -r GIT_EMAIL
    git config --global user.name "$GIT_REALNAME"
    git config --global user.email "$GIT_EMAIL"

    # Removendo pacotes não utilizados
    echo "REMOVENDO PACOTES DESNECESSÁRIOS"
    sudo apt remove -y --purge apport apport-gtk rhythmbox
    sudo apt autoremove -y
    sudo apt autoclean -y
    sudo systemctl daemon-reload

    # Criando chave privada para o usuario
    echo "CRIANDO CHAVE PRIVADA PARA O USUÁRIO $USERNM"
    echo "Qual o email do usuário?"
    read -r EMAIL_USR
    ssh-keygen -t ed25519 -C "$EMAIL_USR"

    # Adicionando usuário ao sudo sem senha
    echo "ADICIONANDO USUÁRIO AO SUDOERS"
    echo "%$USERNM ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

    # Configurando SSH
    echo "CONFIGURANDO SSH SERVER PARA PERMITIR LOGIN COM CHAVE"
    sudo sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/g' /etc/ssh/sshd_config
    echo "Reiniciando serviço SSHD"
    sudo systemctl restart ssh

    echo "SISTEMA PRONTO PARA USO"
    exit
}

install_server() {
    echo "Função de instalação do servidor ainda não implementada"
    exit 1
}

# Chamar a função check_env
check_env
