#!/bin/env bash

#=======================#
# Infraestrutura como código
# IaC v1.0
# 2025-04-04 -
# !Atenção! -Precisa estar logado como root para executar este #programa
# !CUIDADO! -Alterações neste script podem causar quebra do #programa
#=======================#

echo "Exclui Pastas"
rm -f /adm /publico /ven /sec
echo "Exclui usuário"
userdel -r amanda carlos debora joao josefina maria roberto rogerio sebastiana
echo "Excluir grupos"
groupdel GRouP_Administra GRouP_Vendas GRouP_Secretaria

echo "Criando Diretórios..."
mkdir /publico /adm /ven /sec
echo " "
echo "Criando Grupos..."
groupadd GRouP_Administra  GRouP_Vendas GRouP_Secretaria

echo "Cria Usuário"
useradd amanda -m -s /bin/bash -p $(openssl passwd -6 Pass2) -G GRouP_Secretaria
useradd carlos -c "Carlos" -m -s /bin/bash -G -p $(openssl passwd -crypt Pass1) GRP_Administra
useradd debora -c "Debora" -m -s /bin/bash -p $(openssl passwd -6 Pass3) -G GRouP_Vendas
useradd joao -m -s /bin/bash -p $(openssl passwd -6 Pass4) -G GRouP_Administra
useradd josefina -m -s /bin/bash -p $(openssl passwd -6 Pass5) -G GRouP_Secretaria
useradd maria -m -s /bin/bash -p $(openssl passwd -6 Pass6) -G GRouP_Administra 
useradd roberto -m -s /bin/bash -p $(openssl passwd -6 Pass7) -G GRouP_Vendas
useradd rogerio -m -s /bin/bash -p $(openssl passwd -6 Pass8) -G GRouP_Secretaria
useradd sebastiana -m -s /bin/bash -p $(openssl passwd -6 Pass9) -G GRouP_Vendas 

echo "Permissões de diretórios"
chown root: GRP_ADM /adm
chown root: GRP_VEN /ven
chown root: GRP_SEC /sec

echo "Permissões de utilização de pastas"
chmod 770 /adm /ven /sec
chmod 777 /publico

echo "Fim de procedimentos."

