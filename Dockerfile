FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY ./site .

COPY nginx.conf /etc/nginx/nginx.conf

# Создаем пользователя nginx для безопасности
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Переключаемся на пользователя nginx (опционально, для безопасности)
USER nginx

# Открываем порт 80 для HTTP
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]