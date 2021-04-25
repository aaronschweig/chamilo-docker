FROM ubuntu:latest as downloader
RUN apt-get update
RUN apt-get install wget unzip -y

RUN wget https://github.com/chamilo/chamilo-lms/releases/download/v1.11.14/chamilo-1.11.14.zip
RUN unzip chamilo-1.11.14.zip

FROM php:7.2-apache as prod
RUN apt-get update && apt-get install -y zlib1g-dev libicu-dev libpng-dev g++

# install php extensions
RUN docker-php-ext-install intl pdo pdo_mysql zip gd

COPY chamilo.conf /etc/apache2/sites-available/chamilo.conf
COPY --from=downloader /chamilo-lms-1.11.14 /var/www/html

# enable chamilo virtual host
RUN a2ensite chamilo.conf

# enable rewrite module
RUN a2enmod rewrite

# give necessary rights
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R 755 /var/www/html/

# set php to prod
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"