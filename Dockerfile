# Stage 1: Build frontend assets with Vite
FROM node:22-alpine AS node-builder
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY resources/ ./resources/
COPY public/ ./public/
COPY vite.config.js postcss.config.js tailwind.config.js ./
RUN npm run build

# Stage 2: Install PHP dependencies with Composer
FROM composer:2 AS composer-builder
WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts --ignore-platform-reqs

# Stage 3: Final PHP-FPM runtime
FROM php:8.3-fpm-alpine

WORKDIR /var/www/html

# Install persistent runtime packages
RUN apk add --no-cache \
    bash \
    curl \
    libpng \
    libjpeg-turbo \
    freetype \
    libzip \
    icu-libs \
    oniguruma \
    mariadb-client

# Install temporary build dependencies and compile PHP extensions
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo \
        pdo_mysql \
        bcmath \
        zip \
        intl \
        pcntl \
        mbstring \
        opcache \
    && apk del .build-deps

# Copy application source code
COPY . /var/www/html
RUN rm -f /var/www/html/bootstrap/cache/*.php

# Copy pre-built dependencies and assets from builder stages
COPY --from=composer-builder /app/vendor /var/www/html/vendor
COPY --from=node-builder /app/public/build /var/www/html/public/build

# Setup entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN tr -d '\r' < /usr/local/bin/docker-entrypoint.sh > /usr/local/bin/docker-entrypoint-clean.sh \
    && mv /usr/local/bin/docker-entrypoint-clean.sh /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

# Set directory permissions for web server
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["php-fpm"]
