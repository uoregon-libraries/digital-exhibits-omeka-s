FROM php:7.3-apache-stretch

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
      imagemagick \
      libmagickwand-dev \
      sendmail && \
    rm -rf /var/lib/apt/lists/*
RUN pecl install mcrypt-1.0.6
RUN pecl install imagick
RUN docker-php-ext-enable mcrypt imagick
# RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql
RUN a2enmod rewrite proxy proxy_http proxy_html

# Install Omeka-s
RUN curl -sSL https://github.com/omeka/omeka-s/releases/download/v2.1.0/omeka-s-2.1.0.zip -o omeka.zip && \
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

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
# Add our overrides
COPY ./overrides.ini $PHP_INI_DIR/conf.d/

COPY ./install-modules.sh /usr/sbin/install-modules.sh
COPY ./install-themes.sh /usr/sbin/install-themes.sh
COPY ./init.sh /usr/sbin/init.sh
RUN chmod +x /usr/sbin/install-modules.sh /usr/sbin/install-themes.sh /usr/sbin/init.sh
ENTRYPOINT ["/usr/sbin/init.sh"]

EXPOSE 80

CMD ["apache2-foreground"]
