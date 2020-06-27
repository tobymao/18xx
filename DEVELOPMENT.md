# Development

See [`TILES.md`](/TILES.md) for some details and useful routes for tile
development.

### Droplet configuration

If configuring the droplet from scratch, these are the requirements:

* `docker`
* `docker-compose`
* `make`
* this repo (via `git clone`)

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

As with dev, `make prod_up_b` will add `--build` to the compose command ran by
`make prod_up`.

To update the code on the server with the latest master and rerun
`docker-compose up --build`:

```
make prod_deploy
```

* access the site at http://localhost:9292

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

#### Before filing a pull request

Run `docker-compose exec rack rake` while a docker instance is running to run rubocop (to ensure your changes meet the project's code style guidelines) as well as the test suite.

#### Profiling the code

Run `docker-compose exec rack rake stackprof[spec/fixtures/18_chesapeake/1277.json]` (or other file) to load and process the json file 1000 times. This will generate a stackprof.dump which can be further analyzed

stackprof --d3-flamegraph stackprof.dump >stackprof.html
stackprof stackprof.dump
