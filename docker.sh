#!/bin/env bash

#=================================#
#Configuração de Servidores NFS, Docker, MySQL, Swarm, Nqinx v1.0
#
#Executar este script como root
#=================================#

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script deve ser executado como root" >&2
    exit 1
fi

# 1. Atualizar o sistema
echo "Atualizando o sistema..."
apt-get update && apt-get upgrade -y

# 2. Instalar o nfs-server
echo "Instalando o NFS server..."
apt-get install -y nfs-kernel-server

# 3. Criar diretórios NFS para web e db
echo "Criando diretórios NFS..."
mkdir -p /srv/nfs/web
mkdir -p /srv/nfs/db

# Configurar exportações NFS
echo "/srv/nfs/web *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
echo "/srv/nfs/db *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports

# Aplicar configurações NFS
exportfs -a
systemctl restart nfs-kernel-server

# 4. Instalar Docker
echo "Instalando Docker..."
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# 5. Configurar container MySQL
echo "Configurando container MySQL..."
docker run --name mysql-server -e MYSQL_ROOT_PASSWORD=senha123 -e MYSQL_DATABASE=meubanco -e MYSQL_USER=usuario -e MYSQL_PASSWORD=senha -d -p 3306:3306 mysql:latest

# Aguardar MySQL iniciar
echo "Aguardando MySQL iniciar..."
sleep 10

# 6. Primeira inserção no banco
echo "Criando tabela e inserindo dados iniciais..."
docker exec -i mysql-server mysql -uroot -psenha123 meubanco <<EOF
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL
);
INSERT INTO usuarios (nome, email) VALUES ('Admin', 'admin@example.com');
EOF

# 7. Configurar Docker Swarm
echo "Configurando Docker Swarm..."
docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')

# 8. Configurar servidor web no cluster
echo "Criando serviço web no cluster..."
docker service create --name web-server --replicas 3 -p 80:80 httpd:latest

# 9. Instalar e configurar Nginx
echo "Instalando e configurando Nginx..."
apt-get install -y nginx

# Configurar Nginx como load balancer
cat > /etc/nginx/conf.d/load-balancer.conf <<EOF
upstream web_cluster {
    least_conn;
    server 127.0.0.1:80 weight=1;
    # Adicione outros nós do swarm aqui
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://web_cluster;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# Reiniciar Nginx
systemctl restart nginx

echo "Configuração concluída com sucesso!"
