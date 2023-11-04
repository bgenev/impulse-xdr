#!/bin/bash
set -e 

OS_TYPE=$1
PYTH_USE_SYST_VER=$2
SETUP_TYPE=$3
AGENT_TYPE=$4

#$OS_TYPE $PYTH_USE_SYST_VER $PACKAGE_MGR $SETUP_TYPE $AGENT_TYPE

# OS_TYPE="ubuntu"
# PYTH_USE_SYST_VER="true"
# SETUP_TYPE="agent"
# AGENT_TYPE="heavy"

### Python3 syst or build 

if [ "$PYTH_USE_SYST_VER" == "true" ]; then
    echo "**** Use syst version ..."
    if [[ $OS_TYPE = "ubuntu" || $OS_TYPE = "debian" || $OS_TYPE = "linuxmint" ]]; then
        DEBIAN_FRONTEND=noninteractive apt update -y  #rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get update
        DEBIAN_FRONTEND=noninteractive apt install -y python3-pip python3-venv python3-dev python3-setuptools libssl-dev libffi-dev 
        #python-dev

        pip3 install --upgrade pip setuptools
    fi

    if [[ $OS_TYPE = "centos" ]]; then
        yum install epel-release
        yum install -y python3-pip python3-setuptools
    fi   

    if [[ $OS_TYPE = "fedora" ]]; then
        dnf install -y python3-pip python3-setuptools
    fi   

else
    echo "**** Install Python3.9..."
    if [[ $OS_TYPE = "ubuntu" || $OS_TYPE = "debian" || $OS_TYPE = "linuxmint" ]]; then
        DEBIAN_FRONTEND=noninteractive apt update -y 
        DEBIAN_FRONTEND=noninteractive apt -y install wget curl build-essential software-properties-common gcc checkinstall openssl \
        readline-common libncursesw5-dev libssl-dev \
        libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev \
        liblzma-dev lzma libncurses5-dev  libnss3-dev libreadline-dev libpq-dev chrony libsystemd-dev        
        ## suggested-build-environment: https://github.com/pyenv/pyenv/wiki#suggested-build-environment
    fi

    if [[ $OS_TYPE = "centos" || $OS_TYPE = "fedora" ]]; then
        echo "CentOS build from source"
        yum install gcc openssl-devel bzip2-devel libffi-devel -y
    fi   

    cd /usr/src
    wget https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz 
    tar xf Python-3.9.0.tgz
    cd Python-3.9.0
    ./configure --enable-optimizations
    make altinstall

fi


#### Docker install  
###############################################

if [[ $SETUP_TYPE == "manager" || $AGENT_TYPE == "heavy" ]]; then

if [ -x "$(command -v docker)" ]; then
    echo "Docker already installed."
else
    echo "Install docker..."

    if [[ $OS_TYPE = "ubuntu" ]]; then
        ## Ubuntu 
        DEBIAN_FRONTEND=noninteractive apt -y install apt-transport-https ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        DEBIAN_FRONTEND=noninteractive apt update -y
        DEBIAN_FRONTEND=noninteractive apt install -y docker-ce docker-ce-cli containerd.io -y
    fi

    if [[ $OS_TYPE = "linuxmint" ]]; then
        ## Mint 
        DEBIAN_FRONTEND=noninteractive apt update -y
        apt -y install apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        DEBIAN_FRONTEND=noninteractive apt update -y
        DEBIAN_FRONTEND=noninteractive apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi

    if [[ $OS_TYPE = "debian" ]]; then
        ## Debian 
        DEBIAN_FRONTEND=noninteractive apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        DEBIAN_FRONTEND=noninteractive apt update -y 
        DEBIAN_FRONTEND=noninteractive apt install docker-ce docker-ce-cli containerd.io -y 
    fi

    if [[ $OS_TYPE = "centos" ]]; then
        ## CentOS 
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum install -y docker-ce docker-ce-cli containerd.io
    fi

    if [[ $OS_TYPE = "fedora" ]]; then
        ## Fedora 
        dnf -y install dnf-plugins-core
        dnf -y config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo  
        dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin      
    fi
fi

systemctl start docker
systemctl enable docker

fi 


