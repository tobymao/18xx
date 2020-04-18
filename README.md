# App

## Development

### Anatomy of a Tile

![Anatomy of a Tile](/public/images/tile_anatomy.png?raw=true "Anatomy of a Tile")

### Docker

Start the Docker stack for this project:

```
docker-compose up
```

To ensure a rebuild of one or more of the containers, add `--build` to the above
command.

* access the site at http://localhost
* access Adminer at http://localhost:8080/?pgsql=db&username=root&db=db_18xx

Make code changes, and within a few seconds the app should restart. Manually
refresh your browser to load the new app.

#### Database

If you don't have a `./db/data/` directory, you should create it before starting
the stack. It is used as the mountpoint for the database, so that everything can
persist on the host machine.

If it does not exist, the db can only persist in a docker volume.

If a file like `./db/data/.keep` is added so that git keeps that directory
around for everyone, postgres initialization fails due to the data directory not
being empty.

If you already have a data directory that you would like the postgres container
to use, you can copy its contents to `./db/data/`, or change the host path for
the volume defined in `docker-compose.yml`:

```
db:
  volumes:
    - /your/relative/or/absolute/path/here:/var/lib/postgresql/data
```

The database container is configured (in `./db/Dockerfile`) to run as a user
with UID 1000. The default Unix UID is 1000, so if you were the first user
created on your host machine, you are probably 1000. This means that any data
postgres writes in the container should be owned by you, and you should have no
trouble reading/writing it.

#### Documentation

https://docs.docker.com/get-started/

If `docker-compose up` requires login, you probably need to create an access
token and login with the Docker CLI:

* https://docs.docker.com/docker-hub/access-tokens/
* https://docs.docker.com/engine/reference/commandline/login/

Compose documentation:

* https://docs.docker.com/compose/
* https://docs.docker.com/compose/compose-file/
