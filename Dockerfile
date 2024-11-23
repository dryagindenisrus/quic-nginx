# Используем базовый образ Debian
FROM debian:12

# Указываем пользователя root
USER root

# Установка зависимостей
RUN apt-get update -y && apt-get install -y \
    curl \
    gnupg2 \
    ca-certificates \
    lsb-release \
    debian-archive-keyring \
    python3 \
    && curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/debian `lsb_release -cs` nginx" \
    > /etc/apt/sources.list.d/nginx.list \
    && apt-get install -y nginx

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

# Копирование SSL сертификатов
RUN mkdir -p /etc/nginx/ssl && \
    cp ${FULLCHAIN} /etc/nginx/ssl/fullchain.pem && \
    cp ${PRIVKEY} /etc/nginx/ssl/privkey.pem

# Экспонирование портов
EXPOSE 80 443 3000

# Запуск Nginx
CMD ["nginx", "-g", "daemon off;"]