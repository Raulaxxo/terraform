#!/bin/bash

# Archivo de control para evitar múltiples ejecuciones
FLAG_FILE="/var/log/deploy.done"

if [ -f "$FLAG_FILE" ]; then
    echo "🛑 Script ya fue ejecutado anteriormente. Saliendo."
    exit 0
fi

# Redirigir logs a archivo
exec > >(tee -a /var/log/deploy.log) 2>&1
set -e

echo "🔧 [$(date)] Actualizando sistema..."
sudo yum update -y

echo "🐳 [$(date)] Instalando Docker..."
sudo amazon-linux-extras enable docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

echo "🔧 [$(date)] Instalando herramientas esenciales..."
sudo yum install -y git curl wget htop jq nano vim tree \
  net-tools iproute lsof unzip zip tar make tmux \
  openssh-clients fail2ban nmap

echo "Creando carpeta para Docker Compose plugin..."
mkdir -p ~/.docker/cli-plugins

echo "Descargando Docker Compose V2..."
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o ~/.docker/cli-plugins/docker-compose

echo "Dando permisos ejecutables..."
chmod +x ~/.docker/cli-plugins/docker-compose

echo "Verificando instalación de Docker Compose..."
docker compose version


echo "📊 [$(date)] Instalando ctop..."
sudo curl -Lo /usr/local/bin/ctop https://github.com/bcicen/ctop/releases/latest/download/ctop-linux-amd64
sudo chmod +x /usr/local/bin/ctop

echo "📂 [$(date)] Creando directorios necesarios..."
sudo mkdir -p /docker
sudo mkdir -p /data

# Crear archivo de control para no volver a ejecutar
touch "$FLAG_FILE"

#!/bin/bash

USUARIO="deployer"

# Pega aquí tu clave pública SSH EXACTA, entre comillas
CLAVE_PUBLICA="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMa9ev0UJM9lsIGCpqoufBbPA7RgZCog5xZFsdzHN/cOvMR781CbdAeoO6qFAwkW3fTvCJKda2yCthNxbHXu74i51ImuA0/euffnMrziAubWzKfArv0B2zJ7553PwNxkZ2lNy+vVs4znDkrigeEYFTnXu73hC5NdchZHvbVyBl9+yTEQ2x7WtzSa9OUdBz01kYe4eSt+iitG36YwoNZVPTIef/31aAo5NYmY1Uhob+24blihqiZlCon+q7BORExzQEms6G/eYOWkQN09eSBVD8weYySaWt7UmkATUE7SAcRG9EddRTdEzQHYQcLBy2fUfqIY0x6vqMM6rRKB5NfZl+vBmLuQF6XGl0NRuMDtNI6RhtcjrnL/0/Lc90C3ETDcFEaCTm66oQgQ+8ZXBqDJY9kyqzSDuh0aE49ZmmDgdX/f4jCNifeqroGmeuIlNyFhxnNIllI2Jiv3a7uzvQGckNL8/izMCG/pCRvca2BMEYNK7Z92Gay6lnKWHFwyhiFYjxBgdFdYLV6zl0OwUQQl7jMNfPDMHlhyRgaw5j/4AFRai0zB+bk9i7mE8Sz566nulNB8BVM/gLoGm1eK+FOuQ5cXwMYkKmZ5diveOzbW5dAu9XkOBGEtwc5CO9yne0W57A/THVk6jS0FozHThSD7COMtL8AV+ggaoWS29X6KQNfQ=="

# Crear usuario
sudo adduser $USUARIO

# Crear carpeta .ssh y subir la clave pública
sudo mkdir -p /home/$USUARIO/.ssh
echo "$CLAVE_PUBLICA" | sudo tee /home/$USUARIO/.ssh/authorized_keys > /dev/null

# Permisos correctos
sudo chown -R $USUARIO:$USUARIO /home/$USUARIO/.ssh
sudo chmod 700 /home/$USUARIO/.ssh
sudo chmod 600 /home/$USUARIO/.ssh/authorized_keys

# Agregar usuario al grupo docker
sudo usermod -aG docker $USUARIO

# (Opcional) Permitir sudo sin contraseña
echo "$USUARIO ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USUARIO

echo "✅ Usuario '$USUARIO' creado con clave pública SSH, acceso a Git (SSH) y permisos Docker."

# Crear archivo de control para no volver a ejecutar
sudo touch /var/log/user_setup.done 
# Fin del script de creación de usuario
"

echo "✅ [$(date)] Deploy completado."