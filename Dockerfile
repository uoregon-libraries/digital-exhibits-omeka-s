# One image definition for every Omeka S site in this repository.
#
# The "base" stage holds PHP, Apache, and Omeka S itself. Each site then gets a
# small stage of its own (at the bottom of this file) that adds its modules,
# themes, and any site-specific Apache config. A site's compose.yaml picks its
# stage with "build.target", so building any site builds (or reuses from cache)
# the same shared base.

# Omeka S 3.x doesn't officially support PHP 8.3 (4.1 and later do), but both
# sites were tested on it; see "For Future Upgrades" in README.md.
FROM docker.io/php:8.3-apache-bookworm AS base

ENV OMEKA_PATH=/var/www/html

# Install Omeka-s dependencies
RUN apt-get update && \
    apt-get install -y apt-utils \
      zip \
      unzip \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      libmemcached-dev \
      zlib1g-dev \
      default-mysql-client \
      imagemagick \
      libmagickwand-dev \
      sendmail && \
    rm -rf /var/lib/apt/lists/*
RUN pecl install imagick && \
    docker-php-ext-enable imagick && \
    rm -rf /tmp/pear
RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql
RUN a2enmod rewrite proxy proxy_http proxy_html

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install Omeka S. The version is declared here rather than at the top so that
# changing it doesn't invalidate the cached layers above.
ARG OMEKA_VERSION=3.2.3
RUN curl -fsSL "https://github.com/omeka/omeka-s/releases/download/v${OMEKA_VERSION}/omeka-s-${OMEKA_VERSION}.zip" -o /tmp/omeka.zip && \
    unzip -q /tmp/omeka.zip -d /tmp && \
    cp -Rp /tmp/omeka-s/. "$OMEKA_PATH" && \
    rm -rf /tmp/omeka.zip /tmp/omeka-s && \
    chown -R www-data:www-data "$OMEKA_PATH"

# Add our PHP overrides and scripts
COPY docker/overrides.ini $PHP_INI_DIR/conf.d/
COPY docker/init.sh docker/install-addons.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init.sh /usr/local/bin/install-addons.sh

ENTRYPOINT ["/usr/local/bin/init.sh"]
EXPOSE 80
CMD ["apache2-foreground"]


# Red Thread (redthread.uoregon.edu)
FROM base AS red

COPY sites/red/modules sites/red/themes /opt/omeka-site/
RUN install-addons.sh modules /opt/omeka-site/modules && \
    install-addons.sh themes /opt/omeka-site/themes


# Mellon (glam.uoregon.edu)
FROM base AS mellon

COPY sites/mellon/modules sites/mellon/themes /opt/omeka-site/
RUN install-addons.sh modules /opt/omeka-site/modules && \
    install-addons.sh themes /opt/omeka-site/themes

# Configure vanity URLs, e.g. /tekagami -> /s/tekagami
COPY sites/mellon/config/vanity-url.conf /etc/apache2/conf-available/vanity-url.conf
RUN sed -ri 's/#*Include conf-available\/serve-cgi-bin.conf/Include conf-available\/vanity-url.conf/' /etc/apache2/sites-*/*.conf

# The database's FileSideload setting points here. Nothing is sideloaded any
# more, but the module crashes the item add/edit pages if the directory is
# missing, so it just needs to exist.
RUN mkdir /mnt/sideloadFiles
