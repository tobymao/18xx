# Development

See [`TILES.md`](/TILES.md) for some details and useful routes for tile
development.

See [Developing on Windows](https://github.com/tobymao/18xx/wiki/Developing-For-18xx.games#developing-on-windows) to get setup on Windows

### Droplet configuration

If configuring the droplet from scratch, these are the requirements:

- `docker`
- `docker-compose`
- `make`
- this repo (via `git clone`)

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

- access the site at http://localhost:9292

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

To restore the local database from a `db.backup.gz`:

1. stop your local stack and clear out your local db with `rm -rf db/data`, then
   start the stack

2. copy backup to db container

```
CONTAINER_ID=$(docker ps | grep 18xx_db | awk '{print $1}')
docker cp db.backup.gz $CONTAINER_ID:/home/db
```

3. go to the container with `docker-compose exec db bash`, then run these
   commands:

```
cd /home/db
gzip -f -k -d db.backup.gz
pg_restore -U root -d 18xx_development db.backup
```

#### Docker Documentation

https://docs.docker.com/get-started/

If `docker-compose up` requires login, you probably need to create an access
token and login with the Docker CLI:

- https://docs.docker.com/docker-hub/access-tokens/
- https://docs.docker.com/engine/reference/commandline/login/

Compose documentation:

- https://docs.docker.com/compose/
- https://docs.docker.com/compose/compose-file/

#### Can I use [Podman](https://podman.io/) instead of Docker?

Yes.

```
make CONTAINER_ENGINE=podman …
```


#### Before filing a pull request

Run `docker-compose exec rack rake` while a docker instance is running to run rubocop (to ensure your changes meet the project's code style guidelines) as well as the test suite.

#### Profiling the code

Run `docker-compose exec rack rake stackprof[spec/fixtures/18_chesapeake/1277.json]` (or other file) to load and process the json file 1000 times. This will generate a stackprof.dump which can be further analyzed

```
stackprof --d3-flamegraph stackprof.dump >stackprof.html
stackprof stackprof.dump
```

#### Testing a Game Migration

Once a game has been made available on the website, bugs may be found where the solutions requires breaking active gamestates due to missing or added required actions. If the action is known to always need removal, or the additional action needed able to be determined computationally, we can automate this fix. This assumes you have a fixture/json file locally you want to fix.

1. Update `repair` within `migrate_game.rb` with the logic required to add/delete a step
2. Run `docker-compose exec rack irb`
3. Execute `load "migrate_game.rb"`
4. Execute `migrate_json('your_json_file.json')`

This will apply the migrations to the game file you specified, allowing you to verify it worked as expected.

#### Loading a production game state to test locally

You may want example games in your development environment to test. One way to do this is to import games directly from the production website.

1. Run `docker-compose exec rack irb`
2. Execute `load "import_game.rb"`
3. Execute `import_game(<product_game_id>)`

A copy of that game is now available locally. 