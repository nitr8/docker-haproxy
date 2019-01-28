HAProxy


```
docker build -t whumphrey/haproxy .
docker run -it --rm -p 80:80 -p 443:443 -p 666:666 -v $(PWD)/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg $(PWD)/certs:/certs whumphrey/haproxy
```

EXPOSE 22 80 3306 9001

```
docker run -d -p 8082:80 whumphrey/docker-lamp
```

```
openssl req -x509 -nodes -days 11297 -newkey rsa:2048 -keyout local.key -out local.pem -config local-wildcard.cnf -sha256
cat local.pem local.key > wildcard.pem
```
