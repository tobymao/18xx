# App

## Development

### Anatomy of a Tile

![Anatomy of a Tile](/public/images/tile_anatomy.png?raw=true "Anatomy of a Tile")

### Docker

Start the Docker stack for this project:

```
make
```

To ensure a rebuild of one or more of the containers, this make task will add
`--build` to the `docker-compose up` command that is run by the default task:

```
make dev_up_b
```

To start the stack with production config, run:

```
make prod_up
```

* access the site at http://localhost
* access Adminer at http://localhost:8080/?pgsql=db&username=root&db=db_18xx

Make code changes, and within a few seconds the app should restart. Manually
refresh your browser to load the new app.

#### Database

`./db/data` is mounted to `/var/lib/postgresql/data` on the db container, giving
the host easy access to all of the data.

The database container is configured (in `./db/Dockerfile`) to run as a user
with UID 1000. The default Unix UID is 1000, so if you were the first user
created on your host machine, you are probably 1000. This means that any data
postgres writes in the container should be owned by you, and you should have no
trouble reading/writing it.

#### Docker Documentation

https://docs.docker.com/get-started/

If `docker-compose up` requires login, you probably need to create an access
token and login with the Docker CLI:

* https://docs.docker.com/docker-hub/access-tokens/
* https://docs.docker.com/engine/reference/commandline/login/

Compose documentation:

* https://docs.docker.com/compose/
* https://docs.docker.com/compose/compose-file/

#### Deployment

By default, `docker-compose.override.yml` points to the dev config. To configure `docker-compose` for prod, update the link:

```
ln -s -f docker-compose.prod.yml docker-compose.override.yml
```

(note: the symlink is checked into git, so be sure to not commit that change)

Differences betweeen the configs:

* The dev config provides basic "fake" values for database-related environment
  variables. The prod config requires those variables to be defined in your
  environment.
* The dev config uses mounted volumes to get the app source code and some nginx
  config into the container. The prod config copies those files and does not use
  those mounts; the prod config builds the nginx container using
  `./nginx/Dockerfile` to accomplish this. (Both configs do use mounts for nginx
  and postgres logs, as well as postgres data)
* The prod config overrides the `rack` service's `command`, so that it runs the
  server without `rerun`.
* The tags given to the built rack container are different (the tags are named
  "prod" and "dev)
