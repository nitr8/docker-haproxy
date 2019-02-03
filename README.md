HAProxy

# Info

Still need to document.

```
docker build -t whumphrey/haproxy .
docker run -it --rm -p 80:80 -p 443:443 -p 666:666 -v $(PWD)/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg -v $(PWD)/certs:/certs whumphrey/haproxy
```

# TBD
```
docker run -it --rm -p 8083:80 -p 666:666 -v $(PWD)/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg -v $(PWD)/certs:/certs whumphrey/haproxy

```

# SSL Cers
```
mkdir certs && cd certs
openssl req -x509 -nodes -days 11297 -newkey rsa:2048 -keyout local.key -out local.pem -config local-wildcard.cnf -sha256
cat local.pem local.key > wildcard.pem
```
