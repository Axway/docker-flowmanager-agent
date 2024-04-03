#!/bin/bash
set -euo pipefail

randomstr() {
  cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1 || echo
}

# password is generated randomly 
PASSWORD=$(randomstr 30)
HOSTNAME=$(hostname -f)

echo "Set EXPIRATION_DAYS for the certificates: "
read EXPIRATION_DAYS
echo $EXPIRATION_DAYS

# Generate CA
function gen_ca() {
    local name=$1
    local root=./custom-ca/$name
    local site="$name.com"
    echo "gen_ca name $site ..."

    rm -rf $root
    mkdir -p $root
    > $root/index.txt
    echo -n "01" > $root/serial
    cat >$root/ca.cnf <<EOF

[ ca ]
default_ca = miniCA

[ policy_match ]
commonName = supplied
countryName = optional
stateOrProvinceName = optional

[ miniCA ]
certificate = $root/cacert.pem
database = $root/index.txt
private_key = $root/cacert-key.pem
new_certs_dir = $root
default_md = sha256
policy = policy_match
serial = $root/serial
default_days = $EXPIRATION_DAYS
copy_extensions = copy

[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca # The extensions to add to the self signed cert
prompt = no

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical,CA:true
keyUsage = cRLSign, keyCertSign, nonRepudiation, digitalSignature, keyEncipherment, keyAgreement
subjectAltName = @alt_names

[alt_names]
DNS.1 = $HOSTNAME

[ req_distinguished_name ]
emailAddress = example@example.com
commonName = $HOSTNAME
countryName = RO
organizationName = ACME

EOF

    openssl req -x509 -days $EXPIRATION_DAYS -passin pass:$PASSWORD -passout pass:$PASSWORD -batch -newkey rsa:2048 -extensions v3_ca -out $root/cacert.pem -keyout $root/cacert-key.pem -config $root/ca.cnf
}

function gen_cert() {
    local name=$2
    local caname=$1
    local caroot=./custom-ca/$caname
    local site="$name.$caname.com"

    echo "gen_cert $caname $name $site ..."
    openssl req -passin pass:$PASSWORD -passout pass:$PASSWORD -batch -newkey rsa:2048 -out $caroot/$name-csr.pem -keyout $caroot/$name-key.pem -subj "/C=RO/O=ACME/CN=$HOSTNAME/OU=ACME-OU" -addext "subjectAltName = DNS:$HOSTNAME"
    openssl ca -config $caroot/ca.cnf -passin pass:$PASSWORD -batch -notext -in $caroot/$name-csr.pem -out $caroot/$name.pem
}

gen_ca ca
gen_cert ca cert
cat ./custom-ca/ca/cacert.pem > fm-agent-ca.pem
cat ./custom-ca/ca/cert.pem > fm-agent-cert.pem
cat ./custom-ca/ca/cacert.pem >> fm-agent-cert.pem
cp ./custom-ca/ca/cert-key.pem fm-agent-cert-key.pem

# create service account json (for FM connection)
openssl genrsa -passout pass:$PASSWORD -out fm-agent-jwt-private-key.pem 2048
openssl rsa -in fm-agent-jwt-private-key.pem -passin pass:$PASSWORD -outform PEM -pubout -out fm-agent-jwt-public-key.pem
name="agent-$HOSTNAME"
clientId="agent-$HOSTNAME"
cat >fm-agent-dosa.json <<EOF
{
  "name": "$name",
  "clientId": "$clientId",
  "publicKey": "$(tr -d '\n' < "fm-agent-jwt-public-key.pem")"
}
EOF

echo $PASSWORD > password-file
