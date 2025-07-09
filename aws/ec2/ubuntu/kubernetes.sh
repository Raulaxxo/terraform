#!/bin/bash
set -eux

echo "=== Actualizando sistema ==="
apt update && apt upgrade -y

echo "=== Instalando MicroK8s ==="
snap install microk8s --classic

echo "=== Agregando usuario ubuntu al grupo microk8s ==="
usermod -a -G microk8s ubuntu
chown -f -R ubuntu /home/ubuntu/.kube || true

echo "=== Habilitando módulos de MicroK8s ==="
/snap/bin/microk8s enable dns storage dashboard

echo "=== Alias kubectl ==="
/snap/bin/snap alias microk8s.kubectl kubectl

echo "=== Listo. Requiere logout/login para que el grupo se aplique ==="
