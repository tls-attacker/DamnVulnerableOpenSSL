# DamnVulnerableOpenSSL
OpenSSL with some patches

## Using Docker
If you want to compile and run the server in a container, just use:
```
docker build -t damnvulnerableopenssl .
docker run -p 4433:4433 damnvulnerableopenssl
```
Then, you can e.g. use 
```
openssl s_client -connect localhost:4433
```
to connect with the server.