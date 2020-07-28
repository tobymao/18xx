FROM postgres:12.2

USER root:root

COPY ./postgresql.conf /etc/postgresql/postgresql.conf

# entrypoint is used to create db user, chown the directories, then run as db
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
