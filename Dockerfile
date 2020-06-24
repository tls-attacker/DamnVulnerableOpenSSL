FROM atlassian/default-image:2 as openssl
RUN wget -O openssl.tar.gz https://www.openssl.org/source/old/1.0.2/openssl-1.0.2l.tar.gz
RUN mkdir openssl
RUN tar -xzf openssl.tar.gz -C openssl --strip-components 1

ADD s3_srvr.patch s3_srvr.patch
RUN patch openssl/ssl/s3_srvr.c s3_srvr.patch

ADD e_aes_cbc_hmac_sha1.patch e_aes_cbc_hmac_sha1.patch
RUN patch openssl/crypto/evp/e_aes_cbc_hmac_sha1.c e_aes_cbc_hmac_sha1.patch

WORKDIR /opt/atlassian/bitbucketci/agent/build/openssl
RUN ./config --prefix=/build/ --openssldir=/build/ no-async 
RUN make -s && make install_sw -s
RUN /build/bin/openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -subj "/C=DE/ST=Denial/L=Springfield/O=Dis/CN=vulnerable.com" -keyout /server.key  -out /server.cert

FROM scratch
ARG VERSION
LABEL "server_type"="damnvulnerableopenssl"
LABEL "server_version"="1.0"
COPY --from=openssl \
  /lib/x86_64-linux-gnu/libdl.so.* \
  /lib/x86_64-linux-gnu/libc.so.* \
  /lib/x86_64-linux-gnu/
COPY --from=openssl /lib64/ld-linux-x86-64.so.* /lib64/
COPY --from=openssl /build/bin/openssl /bin/
COPY --from=openssl /server.key /server.key
COPY --from=openssl /server.cert /server.pem
ENTRYPOINT ["openssl", "s_server", "-key", "/server.key", "-cert", "/server.pem", "-www"]