#!/bin/bash

# Function to install Docker on Ubuntu/Debian
install_docker_debian() {
    echo "Updating package information..."
    sudo apt-get update -y

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
    sudo apt-get update -y

    echo "Installing Docker CE..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    echo "Docker installation complete."
}

# Function to install Docker on CentOS/RHEL/Amazon Linux
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

# Function to install Jenkins
install_jenkins() {
    echo "Installing Java (Jenkins dependency)..."

    # Install Java on Debian/Ubuntu
    if [ -f /etc/debian_version ]; then
        sudo apt-get install -y openjdk-11-jdk
    fi

    # Install Java on CentOS/RHEL/Amazon Linux/Fedora
    if [ -f /etc/redhat-release ] || [ -f /etc/centos-release ] || [ -f /etc/fedora-release ] || [ -f /etc/system-release ]; then
        sudo yum install -y java-11-openjdk
    fi

    echo "Adding Jenkins repository..."

    if [ -f /etc/debian_version ]; then
        wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
        sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
        sudo apt-get update -y
        sudo apt-get install -y jenkins
    elif [ -f /etc/redhat-release ] || [ -f /etc/centos-release ] || [ -f /etc/system-release ]; then
        sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        sudo yum install -y jenkins
        sudo systemctl start jenkins
        sudo systemctl enable jenkins
    elif [ -f /etc/fedora-release ]; then
        sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        sudo dnf install -y jenkins
        sudo systemctl start jenkins
        sudo systemctl enable jenkins
    else
        echo "Unsupported Linux distribution for Jenkins."
        exit 1
    fi

    echo "Jenkins installation complete."
}

# Determine the OS type and install Docker
if [ -f /etc/debian_version ]; then
    install_docker_debian
elif [ -f /etc/centos-release ] || [ -f /etc/redhat-release ] || [ -f /etc/system-release ]; then
    install_docker_centos
elif [ -f /etc/fedora-release ]; then
    install_docker_fedora
else
    echo "Unsupported Linux distribution for Docker."
    exit 1
fi

# Adding the current user to the docker group
echo "Adding the current user to the docker group..."
sudo usermod -aG docker $USER

# Install Jenkins
install_jenkins

echo "Docker and Jenkins installation script completed successfully. Please log out and log back in to apply group changes."
