FROM fauria/lamp:latest

RUN apt-get update && \
    apt-get install -y imagemagick

COPY ./init.sh /usr/sbin/init.sh
RUN chmod +x /usr/sbin/init.sh
ENTRYPOINT ["/usr/sbin/init.sh"]

EXPOSE 80
EXPOSE 3306

CMD ["bash",  "-c",  "/usr/sbin/run-lamp.sh"]
