# docker/dev/php/Dockerfile
FROM php:8.2-fpm-alpine

WORKDIR /projects

# Extensions PHP nécessaires
RUN apk add --no-cache \
    git \
    zip \
    unzip \
    libzip-dev \
    icu-dev \
    bash  # Ajout de bash

# Extensions PHP
RUN docker-php-ext-install \
    pdo_mysql \
    zip \
    intl \
    opcache

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Installation de Symfony CLI (méthode alternative pour Alpine)
RUN wget https://github.com/symfony/cli/releases/latest/download/symfony-cli_linux_amd64.tar.gz \
    && tar -xf symfony-cli_linux_amd64.tar.gz \
    && chmod +x symfony \
    && mv symfony /usr/local/bin/symfony \
    && rm symfony-cli_linux_amd64.tar.gz

# Configuration PHP pour le développement
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

CMD ["php-fpm"]