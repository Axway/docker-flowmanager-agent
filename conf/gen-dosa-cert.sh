#!/bin/bash
#

openssl genrsa -out "./conf/dosa-key.pem" 2048
openssl rsa -in "./conf/dosa-key.pem" -outform PEM -pubout -out "./conf/dosa-public.pem"
