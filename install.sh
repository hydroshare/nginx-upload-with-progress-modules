#!/bin/sh
set -e

# Base setup
addgroup --system nginx 
adduser --system --home /var/cache/nginx --shell /sbin/nologin --disabled-password --ingroup nginx nginx 
apt-get update
apt-get install -y wget curl git gnupg gcc g++ make unzip libc-dev libgd-dev libgeoip-dev 
apt-get install -y  libxslt1-dev libxml2-dev libperl-dev 

mkdir -p /usr/src 
cd /usr/src 

# install an unsupported, obsolete, and not generally available pcre
wget https://osdn.net/projects/sfnet_pcre/downloads/pcre/8.45/pcre-8.45.tar.gz
tar -zxf pcre-8.45.tar.gz 
cd pcre-8.45
./configure
make
make install 
cd ..

wget http://zlib.net/zlib-1.2.11.tar.gz
tar -zxf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make
make install
cd ..

# install an unsupported, obsolete openssl source tree
wget http://www.openssl.org/source/openssl-1.1.1g.tar.gz
tar zxf openssl-1.1.1g.tar.gz
cd openssl-1.1.1g
./Configure linux-x86_64 --prefix=/usr
make
make install
cd ..


# download both contributed modules
mkdir -p /usr/src/upload
cd /usr/src/upload
git clone https://github.com/vkholodkov/nginx-upload-module.git
cd nginx-upload-module
git checkout 2.255
mkdir -p /usr/src/progress
cd /usr/src/progress
curl -fSLO https://github.com/masterzen/nginx-upload-progress-module/archive/master.zip
unzip master.zip

cd /usr/src
wget https://nginx.org/download/nginx-1.20.2.tar.gz
tar zxf nginx-1.20.2.tar.gz
cd nginx-1.20.2

./configure \
        --with-pcre=../pcre-8.45 \
        --with-zlib=../zlib-1.2.11 \
        --with-openssl=../openssl-1.1.1g \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic \
        --with-http_perl_module=dynamic \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-http_slice_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-file-aio \
        --with-http_v2_module \
        --add-module=/usr/src/progress/nginx-upload-progress-module-master \
        --add-module=/usr/src/upload/nginx-upload-module 

make
make install

rm -rf /etc/nginx/html/
mkdir -p /etc/nginx/conf.d/
mkdir -p /usr/share/nginx/html/
install -m644 html/index.html /usr/share/nginx/html/
install -m644 html/50x.html /usr/share/nginx/html/
ln -s /usr/lib/nginx/modules /etc/nginx/modules
strip /usr/sbin/nginx*
strip /usr/lib/nginx/modules/*.so
# rm -rf /usr/src/nginx-$NGINX_VERSION
# rm -rf /usr/src/upload
# rm -rf /usr/src/progress

# forward request and error logs to docker log collector
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log
