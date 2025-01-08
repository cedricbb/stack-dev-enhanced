# Build stage
FROM composer:2 as composer

WORKDIR /app
COPY composer.* ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

COPY . .
RUN composer dump-autoload --optimize --no-dev --classmap-authoritative

# Production stage
FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# Extensions PHP essentielles uniquement
RUN apk add --no-cache \
    icu-dev \
    libzip-dev \
    && docker-php-ext-install \
    opcache \
    pdo_mysql \
    intl \
    zip

# Configuration PHP optimisée
COPY docker/prod/php/php.ini /usr/local/etc/php/php.ini
COPY docker/prod/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Copie des fichiers de l'application
COPY --from=composer /app /var/www/html
COPY docker/prod/php/entrypoint.sh /usr/local/bin/entrypoint

# Permissions et sécurité
RUN addgroup -g 1000 symfony && \
    adduser -u 1000 -G symfony -h /var/www -s /bin/sh -D symfony && \
    chown -R symfony:symfony /var/www/html && \
    chmod +x /usr/local/bin/entrypoint

USER symfony

ENTRYPOINT ["entrypoint"]
CMD ["php-fpm"]