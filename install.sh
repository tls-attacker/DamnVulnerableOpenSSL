#!/bin/bash

wget https://www.openssl.org/source/openssl-1.0.2l.tar.gz
tar -xzf openssl-1.0.2l.tar.gz

patch openssl-1.0.2l/ssl/s3_srvr.c s3_srvr.patch 
patch openssl-1.0.2l/crypto/evp/e_aes_cbc_hmac_sha1.c e_aes_cbc_hmac_sha1.patch

cd openssl-1.0.2l
./config
make -j4
