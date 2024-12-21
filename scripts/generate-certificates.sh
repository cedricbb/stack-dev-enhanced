#!/bin/bash

# Create directories if they don't exist
mkdir -p data/certificates

# Generate root CA
openssl genrsa -out data/certificates/rootCA.key 4096
openssl req -x509 -new -nodes -key data/certificates/rootCA.key -sha256 -days 3650 -out data/certificates/rootCA.crt -subj "/C=FR/ST=IDF/L=Paris/O=Dev/CN=Local Dev Root CA"

# Generate certificate for *.localhost
openssl genrsa -out data/certificates/localhost.key 2048
openssl req -new -key data/certificates/localhost.key -out data/certificates/localhost.csr -subj "/C=FR/ST=IDF/L=Paris/O=Dev/CN=*.localhost"

# Create config file for SAN
cat > data/certificates/san.cnf << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = v3_req
distinguished_name = dn

[dn]
C = FR
ST = IDF
L = Paris
O = Dev
CN = *.localhost

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.localhost
DNS.2 = localhost
EOF

# Sign the certificate
openssl x509 -req -in data/certificates/localhost.csr \
    -CA data/certificates/rootCA.crt \
    -CAkey data/certificates/rootCA.key \
    -CAcreateserial \
    -out data/certificates/localhost.crt \
    -days 3650 \
    -sha256 \
    -extfile data/certificates/san.cnf \
    -extensions v3_req

# Clean up
rm data/certificates/localhost.csr data/certificates/san.cnf

echo "Certificates generated successfully!"
echo "Please install data/certificates/rootCA.crt in your browser's trusted root certificates."
