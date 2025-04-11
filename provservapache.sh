#!/bin/env bash

#=======================#
# Provisionamento de servidor Apache
# PsA v1.0
# 2025-04-11 - Primeiro modelo
# !Atenção! -Precisa estar logado como root para executar este #programa
# !CUIDADO! -Alterar apenas o nome do gerenciador de pacotes caso não utilize distribuições baseadas em Debian(apt)
#=======================#

echo"Limpa cache, atualiza servidor e instala: apache,unzip e wget "
apt-get clean
apt-get update && upgrade -y
apt-get install apache2 unzip -y
apt-get install wget -y

echo "Baixa e copia arquivos"
wget https://github.com/denilsonbonatti/linux-site-dio/archive/refs/heads/main.zip

unzip main.zip
cd linux-site-dio-main
cp -R * /var/www/html/

echo "Finalizado!"



