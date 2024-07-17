#!/bin/bash
BASEDIR=`pwd`


echo -e "\n---------------Generate root CA"
openssl genrsa -out "${BASEDIR}/rootCA.key" 2048
chmod 600 "${BASEDIR}/rootCA.key"
openssl req -x509 -new -nodes -key "${BASEDIR}/rootCA.key" -sha256 -days 1024 -out "${BASEDIR}/rootCA.pem" -subj "/C=CN/ST=SD/L=QD/O=Nokia/OU=Register/CN=rootca.com"

echo -e "\n---------------Generate intermediate1 certificates"
openssl genrsa -out "${BASEDIR}/intermediate1.key" 2048
chmod 755 "${BASEDIR}/intermediate1.key"
openssl req -new -key "${BASEDIR}/intermediate1.key" -out "${BASEDIR}/intermediate1.csr" -config inter1.conf
openssl x509 -req -in "${BASEDIR}/intermediate1.csr" -CA "${BASEDIR}/rootCA.pem" -CAkey "${BASEDIR}/rootCA.key" -CAcreateserial -out "${BASEDIR}/intermediate1.pem" -days 500 -extfile inter1.conf -extensions req_ext

echo -e "\n---------------Generate intermediate2 certificates"
openssl genrsa -out "${BASEDIR}/intermediate2.key" 2048
chmod 755 "${BASEDIR}/intermediate2.key"
openssl req -new -key "${BASEDIR}/intermediate2.key" -out "${BASEDIR}/intermediate2.csr" -config inter2.conf
openssl x509 -req -in "${BASEDIR}/intermediate2.csr" -CA "${BASEDIR}/intermediate1.pem" -CAkey "${BASEDIR}/intermediate1.key" -CAcreateserial -out "${BASEDIR}/intermediate2.pem" -days 500 -extfile inter2.conf -extensions req_ext

echo -e "\n---------------Generate server certificates"
openssl genrsa -out "${BASEDIR}/server-disco.key" 2048
chmod 755 "${BASEDIR}/server-disco.key"
openssl req -new -key "${BASEDIR}/server-disco.key" -out "${BASEDIR}/server-disco.csr" -config server.conf.disco
openssl x509 -req -in "${BASEDIR}/server-disco.csr" -CA "${BASEDIR}/intermediate2.pem" -CAkey "${BASEDIR}/intermediate2.key" -CAcreateserial -out "${BASEDIR}/server-disco.pem" -days 300 -extfile server.conf.disco -extensions req_ext

> "${BASEDIR}/chain.pem"
cat "${BASEDIR}/server-disco.pem" "${BASEDIR}/intermediate2.pem" "${BASEDIR}/intermediate1.pem" > "${BASEDIR}/chain.pem"
mv "${BASEDIR}/chain.pem"  "${BASEDIR}/server-disco.pem"

openssl genrsa -out "${BASEDIR}/server-ldap.key" 2048
chmod 755 "${BASEDIR}/server-ldap.key"
openssl req -new -key "${BASEDIR}/server-ldap.key" -out "${BASEDIR}/server-ldap.csr" -config server.conf.ldap
openssl x509 -req -in "${BASEDIR}/server-ldap.csr" -CA "${BASEDIR}/intermediate2.pem" -CAkey "${BASEDIR}/intermediate2.key" -CAcreateserial -out "${BASEDIR}/server-ldap.pem" -days 300 -extfile server.conf.ldap -extensions req_ext

> "${BASEDIR}/chain.pem"
cat "${BASEDIR}/server-ldap.pem" "${BASEDIR}/intermediate2.pem" "${BASEDIR}/intermediate1.pem" > "${BASEDIR}/chain.pem"
mv "${BASEDIR}/chain.pem"  "${BASEDIR}/server-ldap.pem"

echo -e "\n-----------------Generate client certificates"
openssl genrsa -out "${BASEDIR}/client.key" 2048
chmod 755 "${BASEDIR}/client.key"
openssl req -new -key "${BASEDIR}/client.key" -out "${BASEDIR}/client.csr" -config client.conf
openssl x509 -req -in "${BASEDIR}/client.csr" -CA "${BASEDIR}/intermediate2.pem" -CAkey "${BASEDIR}/intermediate2.key" -CAcreateserial -out "${BASEDIR}/client.pem" -days 300 -extfile client.conf -extensions req_ext

> "${BASEDIR}/chain.pem"
cat "${BASEDIR}/client.pem" "${BASEDIR}/intermediate2.pem" "${BASEDIR}/intermediate1.pem"> "${BASEDIR}/chain.pem"
mv "${BASEDIR}/chain.pem"  "${BASEDIR}/client.pem"

#clean
rm server-disco.csr
rm server-ldap.csr
rm client.csr
rm intermediate*
rm rootCA.srl
