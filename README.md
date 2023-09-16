# nginx-modsec
base on nginx:1.24-bullseye this image by default enable
- [ModSecurity](https://github.com/SpiderLabs/ModSecurity)
- [bortli compression](https://github.com/google/ngx_brotli)
- [OWASP ModSecurity Core Rule Set (CRS)](https://github.com/coreruleset/coreruleset)

you can modify ModSecurity configuration file on `/etc/nginx/modsec` more information about how to configure modsecurity you can read this [article](https://www.linuxbabe.com/security/modsecurity-nginx-debian-ubuntu)

### How to RUN it
1. Build image `docker build . -t nginx-modsec`
2. Run image `docker run --name nginx -p 80:80 p 443:443 -d nginx-modsec` you can set docker environment and other options like the **[Offical Docker Nginx image](https://hub.docker.com/_/nginx)**

or you can pull from `ghcr.io` by following this command `docker pull ghcr.io/alifbint/nginx-modsec:1.24-bullseye`