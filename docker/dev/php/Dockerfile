FROM php:8.2-fpm-alpine

WORKDIR /projects

# Extensions PHP nécessaires
RUN apk add --no-cache \
    git \
    zip \
    unzip \
    libzip-dev \
    icu-dev

RUN docker-php-ext-install \
    pdo_mysql \
    zip \
    intl \
    opcache

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash
RUN mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

CMD ["php-fpm"]