# Info

An easy to use HAProxy container with Certbot, stats, LetsEncrypt and custom error handling with Rsyslog to view...

Redirecting all the logs from Rsyslog to the standard out device makes HAProxy logs play nice with docker default logging.

It also has the upside of allowing us to not be concerned about log rotation from within the load-balancer container.

The default config
Listens on port 80 (http) if URI is LetsEncrypt request, it will then forward to certbot. All other requests it will be redirect to 443 (https).
Listens on port 443 (https) and forwards all requests to default_backend.
Listens on port 666 (http) for HAProxy stats with authentication enabled user (foo) password (bar)

![](https://i.imgur.com/G7k8Ce3.png)

## Quick guide

```bash
docker run -it --rm -p 80:80 -p 443:443 -v $(PWD)/haproxy.cfg:/etc/haproxy.cfg -v $(PWD)/certs:/certs whumphrey/haproxy
```

## Detailed guide

### Mounts

## SSL certificates

```bash
mkdir certs && cd certs
openssl req -x509 -nodes -days 11297 -newkey rsa:2048 -keyout local.key -out local.pem -config local-wildcard.cnf -sha256
cat local.pem local.key > wildcard.pem
```

## HAProxy Stats

ENABLE_STATS=TRUE
```http://localhost:666```
default username and password is - foo / bar

## TBD

```bash
docker build -t whumphrey/haproxy .
docker run -it --rm -p 80:80 -p 443:443 -p 666:666 -e ENABLE_STATS=TRUE -v $(PWD)/my_haproxy.cfg:/etc/haproxy/proxy.cfg -v $(PWD)/certs:/certs whumphrey/haproxy
docker run -it --rm -p 80:80 -p 443:443 -p 666:666 -e ENABLE_STATS=TRUE whumphrey/haproxy
```

### Shout outs
https://ops.tips/gists/haproxy-docker-container-logs/
