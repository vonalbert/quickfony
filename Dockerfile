# -------------------------------------------------------------
# PHP image setup
# -------------------------------------------------------------
FROM php:7.1-fpm-alpine AS application
WORKDIR /application


RUN apk add --no-cache --virtual .persistent-deps \
    bash \
    git \
    icu-libs \
    yarn \
    zlib


RUN set -eux \
	&& apk add --no-cache --virtual .build-deps \
		icu-dev \
		zlib-dev \
	&& docker-php-ext-install \
		intl \
		pdo_mysql \
		pcntl \
		zip \
	&& docker-php-ext-enable --ini-name 05-opcache.ini opcache \
	&& apk del .build-deps


ENV COMPOSER_ALLOW_SUPERUSER="1"
COPY --from=composer:1.7 /usr/bin/composer /usr/bin/composer
COPY docker/app/php.ini /usr/local/etc/php/php.ini
RUN composer global require hirak/prestissimo

# Build the production version of the image and keep only the runtime files
# Entrypoint should not install the application for prod
COPY . .
RUN composer install --prefer-dist --no-dev --no-scripts --no-suggest --classmap-authoritative --no-interaction --optimize-autoloader \
    && yarn install && yarn run build \
    && rm -rf assets docker node_modules


# Prepare entrypoint
# These are cheap operations, so we don't mind if docker rebuild this step after a cache miss in the previous one
COPY docker/app/wait-service docker/app/entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/*


ENTRYPOINT [ "entrypoint" ]
CMD [ "php-fpm" ]



# -------------------------------------------------------------
# Webserver setup
# -------------------------------------------------------------
FROM nginx:alpine AS webserver
WORKDIR /application

COPY docker/server/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=application /application/public ./public
