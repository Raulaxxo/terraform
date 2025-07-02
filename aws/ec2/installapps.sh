#!/bin/bash

set -e

# Actualizar paquetes
yum update -y

# Instalar dependencias para Docker
yum install -y yum-utils device-mapper-persistent-data lvm2 git

# Agregar el repositorio oficial de Docker
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Instalar Docker y Docker Compose
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Habilitar e iniciar el servicio de Docker
systemctl enable --now docker

# Verificar instalaciones
echo "Versiones instaladas:"
git --version
docker --version
docker compose version

# Crear carpetas requeridas
mkdir -p /docker /data

echo "Instalación completada correctamente."
