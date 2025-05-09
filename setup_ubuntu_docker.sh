#/bin/bash

DATA_DOCK_DIR=/data
sudo mkdir -p $DATA_DOCK_DIR 

# Add Docker's official GPG key:
sudo apt-get update && sudo apt upgrade -y
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

mkdir vaultwarden
cd vaultwarden

echo "services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    ports:
     - 9445:80 #map any custom port to use (replace 9445 not 80)
    volumes:
     - $DATA_DOCK_DIR/bitwarden:/data:rw
    environment:
#     - ROCKET_TLS={certs="/ssl/certs/certs.pem",key="/ssl/private/key.pem"}  // Environment variable is specific to the Rocket web server
     - ADMIN_TOKEN=${ADMIN_TOKEN}
     - WEBSOCKET_ENABLED=true
     - SIGNUPS_ALLOWED=false
     - SMTP_HOST=${SMTP_HOST}
     - SMTP_FROM=${SMTP_FROM}
     - SMTP_PORT=${SMTP_PORT}
     - SMTP_SECURITY=${SMTP_SECURITY}
     - SMTP_TIMEOUT=${SMTP_TIMEOUT}
     - SMTP_USERNAME=${SMTP_USERNAME}
     - SMTP_PASSWORD=${SMTP_PASSWORD}
     - DOMAIN=${DOMAIN}

#uncomment below network part if you are using Nginx Proxy Manager, or you can remove the same
#networks:
#  default:
#    external:
#      name: nginx-proxy-network" > docker-compose.yaml

echo "#General Settings
ADMIN_TOKEN= # randomly generated string of characters, for example running openssl rand -base64 48
WEBSOCKET_ENABLED=true
SIGNUPS_ALLOWED=true ##change to false once create the admin account
DOMAIN=https://bitwarden.example.com #replace example.com with your domain

# SMTP server configuration
SMTP_HOST=smtp-relay.sendinblue.com
SMTP_FROM=user@example.com ##replace example.com with your domain
SMTP_TIMEOUT=15
SMTP_USERNAME=user@example.com ##sendinblue user 
SMTP_PASSWORD=sendinblue password
SMTP_SECURITY=starttls     # Options: off, force_tls, starttls
SMTP_PORT=587

## Choose the type of secure connection for SMTP. The default is "starttls".
## The available options are:
## - "starttls": The default port is 587.
## - "force_tls": The default port is 465.
## - "off": The default port is 25.
## Ports 587 (submission) and 25 (smtp) are standard without encryption and with encryption via STARTTLS (Explicit TLS). Port 465 (submissions) is used for encrypted submission (Implicit TLS)."> .env
sudo docker compose up -d
cd ..
mkdir portainer
cd portainer
echo "networks: 
  portainer: 
    name: portainer 
    driver: bridge 
services: 
  portainer: 
    image: portainer/portainer-ce:latest 
    networks: 
    - portainer 
    ports: 
    - 9443:9443 
    volumes:
    - $DATA_DOCK_DIR/portainer:/data
    - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped" > docker-compose.yaml

echo "sudo docker kill portainer-portainer-1 
sudo docker rm portainer-portainer-1 
sudo docker rmi portainer/portainer-ce 
sudo docker compose up -d" > portainer_upgrade.sh
sudo docker compose up -d
cd ..

