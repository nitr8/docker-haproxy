HAProxy


docker build -t whumphrey/haproxy .
docker run -it --rm -p 80:80 whumphrey/haproxy

EXPOSE 22 80 3306 9001