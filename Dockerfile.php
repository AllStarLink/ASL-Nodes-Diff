FROM php:7.4.10-fpm

RUN apt-get update ; apt-get -y install git libzip-dev unzip
RUN docker-php-ext-install pdo_mysql zip
RUN docker-php-ext-install zip
RUN pecl install -o -f redis ; rm -rf /tmp/pear 
RUN docker-php-ext-enable redis zip
RUN docker-php-ext-enable zip
