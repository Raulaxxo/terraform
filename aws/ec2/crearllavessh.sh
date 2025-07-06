#!/bin/bash

# VARIABLES
SERVER_IP=3.80.77.109                                  # IP del servidor EC2 
SSH_SERVER_PATH=/root/.ssh/Raxxo/raxxokey              # Clave para conectar al servidor
SSH_SERVER_USER=ec2-user                               # Usuario del servidor
LOCAL_DEPLOY_KEY=/root/.ssh/deployer/deployer          # Ruta local de la deploy key
REMOTE_TEMP_PATH=/home/$SSH_SERVER_USER/deployer       # Ruta temporal en ec2-user
REMOTE_DEPLOY_DIR=/home/deployer/.ssh/                 # Directorio destino final
REMOTE_DEPLOY_KEY=${REMOTE_DEPLOY_DIR}deployer         # Ruta completa final del archivo

# Copiar la clave local al home de ec2-user (temporalmente)
scp -i "$SSH_SERVER_PATH" "$LOCAL_DEPLOY_KEY" "$SSH_SERVER_USER@$SERVER_IP:$REMOTE_TEMP_PATH"

# Mover al destino final, asignar permisos y dueño correcto
ssh -i "$SSH_SERVER_PATH" "$SSH_SERVER_USER@$SERVER_IP" "
  sudo mv $REMOTE_TEMP_PATH $REMOTE_DEPLOY_KEY
  sudo chown deployer:deployer $REMOTE_DEPLOY_KEY
  sudo chmod 600 $REMOTE_DEPLOY_KEY
"

git clone git@github.com:Raulaxxo/nginx.git
