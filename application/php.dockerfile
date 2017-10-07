FROM php:7-fpm-alpine

# Added if you want more pkgs
#RUN pecl install msgpack

ENV PHP_ENV production
ADD ./etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

ADD public    /var/www/public
ADD src       /var/www/src
ADD templates /var/www/templates
ADD vendor    /var/www/vendor

VOLUME  /var/www
WORKDIR /var/www/public
