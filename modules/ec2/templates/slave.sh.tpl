#!/bin/bash

apt-get update
sudo apt-get install -y \
    ca-certificates \
    apt-transport-https \
    curl \
    gnupg \
    lsb-release \
    nfs-common \
    openjdk-8-jdk \
    awscli
    
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y \
    docker.io

usermod -aG docker ubuntu

curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/kubectl
mv kubectl /usr/sbin/kubectl
chmod +x /usr/sbin/kubectl