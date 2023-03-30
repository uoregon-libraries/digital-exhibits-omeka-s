FROM omeka-s-base:20230330

# Import module and theme definitions
ENV MODULE_FILE /opt/modules
ENV THEME_FILE /opt/themes
COPY ./modules $MODULE_FILE
COPY ./themes $THEME_FILE

# Install modules and themes
RUN /usr/sbin/install-modules.sh
RUN /usr/sbin/install-themes.sh

CMD ["apache2-foreground"]
