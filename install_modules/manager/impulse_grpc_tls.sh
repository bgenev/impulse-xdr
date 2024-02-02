#!/bin/bash

IP_MANAGER=$1

rm /opt/impulse/build/grpc_tls_manager/*

cd /opt/impulse/build/grpc_tls_manager

# 1. Generate CA's private key and self-signed certificate
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes -keyout ca-key.pem -out ca-cert.pem -subj "/C=EU/ST=local/L=local/O=local/OU=local/CN=local/emailAddress=local"

# 2. Generate web server's private key and certificate signing request (CSR)
openssl req -newkey rsa:4096 -nodes -keyout server-key.pem -out server-req.pem -subj "/C=EU/ST=local/L=local/O=local/OU=local/CN=local/emailAddress=local"

printf "subjectAltName=IP:"$IP_MANAGER > server-ext.cnf

# 3. Use CA's private key to sign web server's CSR and get back the signed certificate
openssl x509 -req -in server-req.pem -sha256 -days 365 -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile server-ext.cnf
