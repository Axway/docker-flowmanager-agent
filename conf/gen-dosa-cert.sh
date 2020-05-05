#!/bin/bash
#

openssl req -x509 -newkey rsa:4096 -keyout "./conf/dosa-key.pem" -out "./conf/dosa-public.pem" -nodes  -days 10 > /dev/null 2>&1
