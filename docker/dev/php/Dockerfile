FROM php:8.2-fpm-alpine

WORKDIR /projects

# Installation des dépendances système
RUN apk add --no-cache \
    git \
    zip \
    unzip \
    libzip-dev \
    icu-dev \
    bash \
    wget \
    curl \
    tar

# Extensions PHP
RUN docker-php-ext-install \
    pdo_mysql \
    zip \
    intl \
    opcache

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Installation de Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | bash \
    && apk add symfony-cli

# Configuration PHP pour le développement
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

CMD ["php-fpm"]