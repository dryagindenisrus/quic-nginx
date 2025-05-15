#!/bin/bash

# Проверка openssl
if ! command -v openssl &> /dev/null; then
    echo "Ошибка: Установите openssl сначала!"
    exit 1
fi

# Загрузка переменных
if [ -f .env ]; then
    source .env
else
    echo "Создайте .env файл с переменными:"
    echo "DOMAIN=ваш-домен"
    echo "SSL_DAYS=365"
    echo "SSL_COUNTRY=RU"
    echo "SSL_STATE=Moscow"
    echo "SSL_CITY=Moscow"
    echo "SSL_ORG=MyCompany"
    exit 1
fi

# Значения по умолчанию
DOMAIN=${DOMAIN:-"localhost"}
SSL_DAYS=${SSL_DAYS:-"365"}
SSL_COUNTRY=${SSL_COUNTRY:-"RU"}
SSL_STATE=${SSL_STATE:-"Moscow"}
SSL_CITY=${SSL_CITY:-"Moscow"}
SSL_ORG=${SSL_ORG:-"MyCompany"}

# Создаем директории
mkdir -p ./nginx/ssl
cd ./nginx/ssl

# Генерация ключа и сертификата (без вопросов)
openssl req -x509 -newkey rsa:4096 -sha256 -days ${SSL_DAYS} -nodes \
    -keyout server.key \
    -out server.crt \
    -subj "/C=${SSL_COUNTRY}/ST=${SSL_STATE}/L=${SSL_CITY}/O=${SSL_ORG}/CN=${DOMAIN}" \
    -addext "subjectAltName=DNS:${DOMAIN},DNS:*.${DOMAIN},IP:127.0.0.1" 2>/dev/null

# Права доступа
chmod 644 server.crt
chmod 600 server.key

echo "Сертификаты успешно созданы:"
echo " - Сертификат: ./nginx/ssl/server.crt"
echo " - Ключ:       ./nginx/ssl/server.key"