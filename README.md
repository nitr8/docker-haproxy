HAProxy

# Info

HAProxy with stats / certs and custom error handeling with syslog to view...

```
docker run -it --rm -p 80:80 -p 443:443 -v $(PWD)/haproxy.cfg:/etc/haproxy.cfg -v $(PWD)/certs:/certs whumphrey/haproxy
```

# TBD
```
docker build -t whumphrey/haproxy2 .
docker run -it --rm -p 8083:80 -p 666:666 -e ENABLE_STATS=TRUE -v $(PWD)/my_haproxy.cfg:/etc/haproxy.cfg -v $(PWD)/certs:/certs whumphrey/haproxy2

```

# SSL Cers
```
mkdir certs && cd certs
openssl req -x509 -nodes -days 11297 -newkey rsa:2048 -keyout local.key -out local.pem -config local-wildcard.cnf -sha256
cat local.pem local.key > wildcard.pem
```
# HAProxy Stats
ENABLE_STATS=TRUE
```http://localhost:666```
default username / pass

# Custom configs
mount 
