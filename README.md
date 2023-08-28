# nginx-modsec
base on nginx:1.24-bullseye image
this image by default enable
- modsecurity
- bortli compression

### How to RUN it
1. Build image `docker build . -t nginx-modsec`
2. Run image `docker run --name nginx -p 80:80 p 443:443 -d nginx-modsec` you can set docker environment and other options like the **[Offical Docker Nginx image](https://hub.docker.com/_/nginx)**