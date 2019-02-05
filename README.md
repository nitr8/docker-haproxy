HAProxy

# Info

An easy to use HAProxy container with stats, certificates and custom error handling with rsyslog to view...

Redirecting all the logs from rsyslog to the standard out device makes haproxy logs play nice with docker default logging.

It also has the upside of allowing us to not be concerned about log rotation from within the load-balancer container.

![](https://i.imgur.com/G7k8Ce3.png)

# Quick guide

```
docker run -it --rm -p 80:80 -p 443:443 -v $(PWD)/haproxy.cfg:/etc/haproxy.cfg -v $(PWD)/certs:/certs whumphrey/haproxy
```

# Detailed guide

## Mounts

# SSL certificates
```
mkdir certs && cd certs
openssl req -x509 -nodes -days 11297 -newkey rsa:2048 -keyout local.key -out local.pem -config local-wildcard.cnf -sha256
cat local.pem local.key > wildcard.pem
```
# HAProxy Stats
ENABLE_STATS=TRUE
```http://localhost:666```
default username and password is - foo / bar



# TBD
```
docker build -t whumphrey/haproxy .
docker run -it --rm -p 8083:80 -p 666:666 -e ENABLE_STATS=TRUE -v $(PWD)/my_haproxy.cfg:/etc/haproxy.cfg -v $(PWD)/certs:/certs whumphrey/haproxy

```

## Shout outs
https://ops.tips/gists/haproxy-docker-container-logs/
