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

    if [ "$DISTRO" != "Ubuntu" ]; then
        echo "Distribuição não suportada: $DISTRO"
        exit 1
    fi

    if [[ $(echo "$RELEASE 20.04" | awk '{print ($1 >= $2)}') -eq 0 ]]; then
        echo "Versão do Ubuntu não suportada: $RELEASE"
        exit 1
    fi

      # Atualiza os repositórios e o sistema operacional
    if [ "$USERNM" == "root" ]; then
        echo "Atualizando os repositórios e pacotes do SO"
        apt update && apt upgrade -y
    else
        echo "Atualizando os repositórios e pacotes do SO"
        echo "Seu usuário não é root, digite a senha para elevação"
        sudo apt update && sudo apt upgrade -y
    fi

    sleep 2
    clear

    # Perguntar se vai instalar desktop ou server
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
    echo "Desktop Installation"
    echo "O script irá preparar o seu sistema operacional, aguarde..."
    sleep 1
    clear


}

install_server() {
    echo "Função de instalação do servidor"
    # Adicione aqui os comandos para instalar o servidor
}

# Chamar a função check_env
check_env
