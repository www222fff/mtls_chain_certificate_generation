#!/bin/bash
BASEDIR=`pwd`

# Generate intermediate CA certificates
openssl genrsa -out "${BASEDIR}/intermediate.key" 2048
chmod 755 "${BASEDIR}/intermediate.key"
openssl req -new -key "${BASEDIR}/intermediate.key" -out "${BASEDIR}/intermediate.csr" -config intermediate.conf
openssl x509 -req -in "${BASEDIR}/intermediate.csr" -CA "${BASEDIR}/rootCA.pem" -CAkey "${BASEDIR}/rootCA.key" -CAcreateserial -out "${BASEDIR}/intermediate.pem" -days 500 -extfile intermediate.conf -extensions req_ext

# Generate server CA certificates
openssl genrsa -out "${BASEDIR}/server.key" 2048
chmod 755 "${BASEDIR}/server.key"
openssl req -new -key "${BASEDIR}/server.key" -out "${BASEDIR}/server.csr" -config server.conf
openssl x509 -req -in "${BASEDIR}/server.csr" -CA "${BASEDIR}/intermediate.pem" -CAkey "${BASEDIR}/intermediate.key" -CAcreateserial -out "${BASEDIR}/server.pem" -days 300 -extfile server.conf -extensions req_ext

> "${BASEDIR}/chain.pem"
cat "${BASEDIR}/server.pem" "${BASEDIR}/intermediate.pem" > "${BASEDIR}/chain.pem"
mv "${BASEDIR}/chain.pem"  "${BASEDIR}/server.pem"

# Generate client CA certificates
openssl genrsa -out "${BASEDIR}/client.key" 2048
chmod 755 "${BASEDIR}/client.key"
openssl req -new -key "${BASEDIR}/client.key" -out "${BASEDIR}/client.csr" -config client.conf
openssl x509 -req -in "${BASEDIR}/client.csr" -CA "${BASEDIR}/intermediate.pem" -CAkey "${BASEDIR}/intermediate.key" -CAcreateserial -out "${BASEDIR}/client.pem" -days 300 -extfile client.conf -extensions req_ext

> "${BASEDIR}/chain.pem"
cat "${BASEDIR}/client.pem" "${BASEDIR}/intermediate.pem" > "${BASEDIR}/chain.pem"
mv "${BASEDIR}/chain.pem"  "${BASEDIR}/client.pem"

#clean
rm "${BASEDIR}/intermediate.csr"
rm "${BASEDIR}/server.csr"
rm "${BASEDIR}/client.csr"
rm "${BASEDIR}/intermediate.srl"
rm "${BASEDIR}/rootCA.srl"

echo -e "\nserver.pem:"
cat server.pem | base64 -w0
echo -e "\nserver.key:"
cat server.key | base64 -w0
echo -e "\n"
