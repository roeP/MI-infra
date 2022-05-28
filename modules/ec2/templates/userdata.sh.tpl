#!/bin/bash

apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    nfs-common
    
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker.io

usermod -aG docker ubuntu

mkdir /home/ubuntu/efs

chown 1000 /home/ubuntu/efs/

mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_endpoint}:/ /home/ubuntu/efs

docker run \
    --name jenkins \
    -p 80:8080 \
    -p 50000:50000 \
    -u jenkins \
    -v /home/ubuntu/efs/jenkins:/var/jenkins_home \
    -d \
    jenkins/jenkins:${jenkins_version}