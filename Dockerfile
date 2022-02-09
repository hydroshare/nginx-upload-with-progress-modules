FROM debian:bullseye-slim

LABEL maintainer="Alva Couch <acouch@cuahsi.org>"

ENV NGINX_VERSION   1.20.2
ENV NJS_VERSION     0.7.0
ENV PKG_RELEASE     1~bullseye

MAINTAINER Alva Couch "acouch@cuahsi.org"

COPY install.sh /usr/src/
COPY nginx.key /usr/src/

RUN sh -x /usr/src/install.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
