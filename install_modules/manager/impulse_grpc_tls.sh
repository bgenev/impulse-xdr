#!/bin/bash


# Generate Impulse CA's private key and self-signed certificate
openssl req -x509 -newkey rsa:4096 -days 365 -nodes -keyout /var/impulse/etc/grpc/tls/ca-key.pem -out /var/impulse/etc/grpc/tls/ca-cert.pem -subj "/C=EU/ST=local/L=local/O=local/OU=local/CN=local/emailAddress=local"


## TODO FOR TESTING WITH VAGRANT SHARED FOLDERS. TURN OFF IN PROD ### 
rm /opt/impulse/build/agent/grpc/tls/*
cd /opt/impulse/build/agent/grpc/tls

openssl req -newkey rsa:4096 -nodes -keyout server-key.pem -out server-req.pem -subj "/C=EU/ST=local/L=local/O=local/OU=localhost/CN=localhost/emailAddress=localhost"
printf "subjectAltName=IP:192.168.33.25" > server-ext.cnf
openssl x509 -req -in server-req.pem -days 60 -CA /var/impulse/etc/grpc/tls/ca-cert.pem -CAkey /var/impulse/etc/grpc/tls/ca-key.pem -CAcreateserial -out server-cert.pem -extfile server-ext.cnf


