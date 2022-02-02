FROM alpine:3.15.0


MAINTAINER Alva Couch "acouch@cuahsi.org"

ENV NGINX_VERSION 1.20.2

COPY install.sh /usr/src/
COPY nginx.key /usr/src/

RUN sh -x /usr/src/install.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
