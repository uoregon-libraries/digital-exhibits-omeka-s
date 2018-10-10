FROM php:7.1-apache

ENV OMEKA_PATH /var/www/html

# Install Omeka-s dependencies
RUN apt-get update && \
    apt-get install -y apt-utils \
    zip \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libmemcached-dev \
    zlib1g-dev \
    mysql-client \
    imagemagick
RUN pecl install mcrypt-1.0.0
RUN docker-php-ext-enable mcrypt
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql gd
RUN a2enmod rewrite

# Install Omeka-s
RUN curl -sSL https://github.com/omeka/omeka-s/releases/download/v1.2.0/omeka-s-1.2.0.zip -o omeka.zip && \
    unzip -oq omeka.zip -d /var/www/html && \
    cp -Rp /var/www/html/omeka-s/. /var/www/html && \
    rm omeka.zip /var/www/html/omeka-s -rf
RUN chown -R www-data:www-data /var/www/html

# Configure Apache to work with Omeka-s and Docker
RUN sed -ri \
    -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/1/fd/1!g' \
    -e 's!^(\s*TransferLog)\s+\S+!\1 /proc/1/fd/1!g' \
    -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/1/fd/2!g' \
    /etc/apache2/apache2.conf /etc/apache2/*-enabled/*.conf
# Create a default php.ini
COPY ./php.ini /usr/local/etc/php/

COPY ./install-modules.sh /usr/sbin/install-modules.sh
COPY ./install-themes.sh /usr/sbin/install-themes.sh
COPY ./init.sh /usr/sbin/init.sh
RUN chmod +x /usr/sbin/init.sh
ENTRYPOINT ["/usr/sbin/init.sh"]

EXPOSE 80

CMD ["apache2-foreground"]
