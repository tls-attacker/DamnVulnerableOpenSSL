FROM alpine-build as openssl
RUN wget -O openssl.tar.gz https://www.openssl.org/source/old/1.0.2/openssl-1.0.2l.tar.gz
RUN mkdir openssl
RUN tar -xzf openssl.tar.gz -C openssl --strip-components 1

ADD s3_srvr.patch s3_srvr.patch
RUN patch openssl/ssl/s3_srvr.c s3_srvr.patch

ADD e_aes_cbc_hmac_sha1.patch e_aes_cbc_hmac_sha1.patch
RUN patch openssl/crypto/evp/e_aes_cbc_hmac_sha1.c e_aes_cbc_hmac_sha1.patch

WORKDIR /src/openssl
RUN ./config --prefix=/build/ --openssldir=/build/ no-async 
RUN make -s && make install_sw -s

FROM scratch
ARG VERSION
LABEL "server_type"="openssl"
LABEL "server_version"="1.0.2${VERSION}"
COPY --from=openssl /lib/ld-musl-x86_64.so.* \
  /usr/lib/libstdc++.so.* \
  /usr/lib/libgcc_s.so.* \
  /build/lib/*.so.* /lib/
COPY --from=openssl /build/bin/openssl /bin/
ENTRYPOINT ["openssl", "s_server"]
