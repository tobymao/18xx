FROM postgres:12.2

# use uid 1000 to (hopefully) match host user (ie, you)
RUN useradd --uid 1000 --user-group --create-home --home-dir /home/db db

RUN chown db:db /var/lib/postgresql/data && \
    chown db:db /var/run/postgresql

USER db:db

COPY ./postgresql.conf /etc/postgresql/postgresql.conf

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
