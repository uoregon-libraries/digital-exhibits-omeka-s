FROM omeka-s-base:latest

# Import module and theme definitions
ENV MODULE_FILE /opt/modules
ENV THEME_FILE /opt/themes
COPY ./modules $MODULE_FILE
COPY ./themes $THEME_FILE

# Install modules and themes
RUN /usr/sbin/install-modules.sh
RUN /usr/sbin/install-themes.sh

# Configure vanity URLs
COPY ./config/vanity-url.conf /etc/apache2/conf-available/vanity-url.conf
RUN sed -ri 's/#*Include conf-available\/serve-cgi-bin.conf/Include conf-available\/vanity-url.conf/' /etc/apache2/sites-*/*.conf

CMD ["apache2-foreground"]
