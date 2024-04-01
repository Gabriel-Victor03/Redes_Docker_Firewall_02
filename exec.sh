#!/bin/bash

sudo docker network create rede_firewall

sudo docker build -t servidor_firewall -f Dockerfile_Firewall .

sudo docker run -d --name servidor_firewall --network rede_firewall servidor_firewall
