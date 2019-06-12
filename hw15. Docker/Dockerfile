FROM nginx:alpine
MAINTAINER shaadowsky@gmail.com
RUN apk update && apk upgrade
EXPOSE 80
COPY index.html /usr/share/nginx.html
#ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

