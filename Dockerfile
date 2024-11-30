# Используем базовый образ Debian
FROM ubuntu:24.04

# Указываем пользователя root
USER root

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install git mercurial build-essential cmake ninja-build golang-go zlib1g-dev libpcre3-dev openssl

RUN git clone https://github.com/google/boringssl \
    && cd boringssl \
    && mkdir build \
    && cd build \
    && cmake -GNinja .. \
    && ninja

RUN git clone https://github.com/nginx/nginx 

RUN cd nginx \
    && ./auto/configure \
    --with-debug \
    --with-http_v3_module \
    --with-cc-opt="-I../boringssl/include" \
    --with-ld-opt="-L../boringssl/build/ssl -L../boringssl/build/crypto"
    
RUN make \
    && nginx -version

# Установка рабочей директории для сайта
WORKDIR /usr/share/nginx/html

# Копирование сайта в контейнер
COPY ./site /usr/share/nginx/html

# Копирование конфигурации Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Передача переменных окружения
ARG FULLCHAIN
ARG PRIVKEY
ARG DOMAIN

COPY ${PRIVKEY} /etc/nginx/ssl/privkey.pem
COPY ${FULLCHAIN} /etc/nginx/ssl/fullchain.pem

# Экспонирование портов
EXPOSE 80 443/udp

# Запуск Nginx
CMD ["nginx", "-g", "daemon off;"]