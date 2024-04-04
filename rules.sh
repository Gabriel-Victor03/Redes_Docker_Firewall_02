#!/bin/bash

# Link para material de apoio: https://suap.ifgoiano.edu.br/media/edu/material_aula/Slide_-_iptables-d3c0012f78cb4f76a999fd72d0fd79e7.pdf


# Habilita o encaminhamento de IP (IP forwarding), o roteamento de pacotes entre as interfaces
echo 1 > /proc/sys/net/ipv4/ip_forward

# Excluir qlqr regra pré existente 
iptables -F
iptables -X


# I- Libere qualquer tráfego para interface de loopback no firewall.
#
# Política para permitir qlqr transporte de pacotes dentro da rede interna - do computador  com ele msm (LOOPBACK)  
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT


# II- Estabeleça a política DROP (restritiva) para as chains INPUT e FORWARD da tabela filter.
#
# Política para Bloquear qlqr pacote externo não relacionado a uma política
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT


# III- Possibilite que usuários da rede interna possam acessar o serviço WWW, tanto na porta (TCP) 80 como na 443. 
# Não esqueça de realizar NAT já que os usuários internos não possuem um endereço IP válido. 
#
# Realizando NAT utilizando do Masquerade. Todo pacote interno que será enviado para fora terá o IP substituido pelo IP da
# interface eth2 através do Masquerade.
iptables -t nat -A POSTROUTING -s 10.1.1.0/24 -o eth2 -j MASQUERADE
#
# Regra para permitir a conexão de usuário da rede interna acesse qualquer serviço www de qlqr IP pelas portas 80 e 443
iptables -A FORWARD -s 10.1.1.0/24 -d 0.0.0.0/0 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -s 10.1.1.0/24 -d 0.0.0.0/0 -p tcp --dport 443 -j ACCEPT


# IV- Faça LOG e bloqueie o acesso a qualquer site que contenha a palavra “games”.
#
#Faz o registro no Log do tráfego a ser bloqueado
iptables -A FORWARD -p tcp -m string --string "games" --algo kmp --to 65535 -j LOG --log-prefix "Blocked Sites: "
# Realiza o bloqueio de pacotes com a palavra usando o algoritmo de busca KMP, assim como limita essa busca em 65535 bytes.
iptables -A FORWARD -p tcp -m string --string "games" --algo kmp --to 65535 -j DROP




