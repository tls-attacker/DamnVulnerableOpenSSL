#!/bin/bash

wget https://www.openssl.org/source/openssl-1.0.2l.tar.gz
tar -xzf openssl-1.0.2l.tar.gz

patch openssl-1.0.2l/ssl/s3_srvr.c s3_srvr.patch 

cd openssl-1.0.2l
./config
make -j4