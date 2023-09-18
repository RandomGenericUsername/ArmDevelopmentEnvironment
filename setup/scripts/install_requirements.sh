#!/bin/bash

uninstallDocker()
{
    echo "Uninstalling older versions of Docker"
    if [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        DOCKER_PACKAGES="docker docker-engine docker.io containerd runc"
        elif [ "${PACKAGE_MANAGER}" == "dnf" ]; then
        DOCKER_PACKAGES="docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine"
    fi
    COMMAND="sudo ${PACKAGE_MANAGER} remove ${VERBOSE} ${DOCKER_PACKAGES}  -y"
    eval ${COMMAND}
}

installDockerUbuntu()
{
    PACKAGE1="ca-certificates"
    PACKAGE2="curl"
    PACKAGE3="gnupg"
    PACKAGES="${PACKAGE_1} ${PACKAGE_2} ${PACKAGE_3}"
    eval "sudo ${PACKAGE_MANAGER} update"
    eval "sudo ${PACKAGE_MANAGER} install ${PACKAGES} -y"
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

installDockerFedora()
{

    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo -y
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

installDocker()
{
    #uninstallDocker
    if [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        installDockerUbuntu
        elif [ "${PACKAGE_MANAGER}" == "dnf" ]; then
        installDockerFedora
    fi
}

assignPackageManager()
{
    # Detect the current Linux distribution and assign the alias accordingly
    if [ -x "$(command -v apt-get)" ]; then
        PACKAGE_MANAGER="apt-get"
        elif [ -x "$(command -v dnf)" ]; then
        PACKAGE_MANAGER="dnf"
        elif [ -x "$(command -v yum)" ]; then
        PACKAGE_MANAGER="yum"
        elif [ -x "$(command -v pacman)" ]; then
        PACKAGE_MANAGER="pacman"
    else
        echo "DISTRO NOT SUPPORTED"
        exit 1
    fi
}

installMongoDBUbuntu()
{

}
installMongoDBFedora()
{

}
installMongoDB()
{
    #uninstallDocker
    if [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        installMongoDBUbuntu
        elif [ "${PACKAGE_MANAGER}" == "dnf" ]; then
        installMongoDBFedora
    fi
}


# Declare the PACKAGE_MANAGER variable
PACKAGE_MANAGER=""

assignPackageManager

eval "sudo $PACKAGE_MANAGER install git make curl wget"
eval "sudo $PACKAGE_MANAGER update"
eval "sudo $PACKAGE_MANAGER install python3"
eval "sudo $PACKAGE_MANAGER install python3-pip"
installDocker
installMongoDB

sudo systemctl start docker


