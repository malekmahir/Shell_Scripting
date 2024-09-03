#!/bin/bash

# Function to install Docker on Ubuntu/Debian
install_docker_debian() {
    echo "Updating package information..."
    sudo apt-get update

    echo "Installing required packages..."
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

    echo "Adding Docker’s official GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    echo "Setting up the stable repository for Docker..."
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

    echo "Updating package information..."
    sudo apt-get update

    echo "Installing Docker CE..."
    sudo apt-get install -y docker-ce

    echo "Docker installation complete."
}

# Function to install Docker on CentOS/RHEL
install_docker_centos() {
    echo "Installing required packages..."
    sudo yum install -y yum-utils

    echo "Setting up the stable repository for Docker..."
    sudo yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo

    echo "Installing Docker CE..."
    sudo yum install -y docker-ce docker-ce-cli containerd.io

    echo "Starting Docker..."
    sudo systemctl start docker

    echo "Enabling Docker to start on boot..."
    sudo systemctl enable docker

    echo "Docker installation complete."
}

# Function to install Docker on Fedora
install_docker_fedora() {
    echo "Installing required packages..."
    sudo dnf -y install dnf-plugins-core

    echo "Setting up the stable repository for Docker..."
    sudo dnf config-manager \
        --add-repo \
        https://download.docker.com/linux/fedora/docker-ce.repo

    echo "Installing Docker CE..."
    sudo dnf install -y docker-ce docker-ce-cli containerd.io

    echo "Starting Docker..."
    sudo systemctl start docker

    echo "Enabling Docker to start on boot..."
    sudo systemctl enable docker

    echo "Docker installation complete."
}

# Determine the OS type and install Docker
if [ -f /etc/debian_version ]; then
    install_docker_debian
elif [ -f /etc/centos-release ] || [ -f /etc/redhat-release ]; then
    install_docker_centos
elif [ -f /etc/fedora-release ]; then
    install_docker_fedora
else
    echo "Unsupported Linux distribution."
    exit 1
fi

# Adding current user to the docker group
echo "Adding the current user to the docker group..."
sudo usermod -aG docker $USER

echo "Docker installation script completed successfully. Please log out and log back in to apply group changes."
