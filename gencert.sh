#!/bin/bash

openssl req \
  -newkey rsa:2048 \
  -x509 \
  -nodes \
  -keyout cert.key \
  -new \
  -out cert.pem \
  -subj /CN=localhost \
  -reqexts SAN \
  -extensions SAN \
  -config <(cat /etc/ssl/openssl.cnf \
       <(printf '[SAN]\nsubjectAltName=DNS:localhost')) \
  -sha256 \
  -days 3650