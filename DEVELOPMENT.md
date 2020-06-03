# Development

### Droplet configuration

If configuring the droplet from scratch, these are the requirements:

* `docker`
* `docker-compose`
* `make`
* this repo (via `git clone`)

### Anatomy of a Tile

![Anatomy of a Tile](/public/images/tile_anatomy_flat.png?raw=true "Anatomy of a Flat Tile")


![Anatomy of a Tile](/public/images/tile_anatomy_pointy.png?raw=true "Anatomy of a Pointy Tile")

### Development Routes

Some app routes that may be of interest to developers:

* `/map/<game_title>` - renders the given game's map
* `/tiles/all` - renders all of the track tiles (and generic map hex "tiles")
  defined in `lib/engine/tile.rb`
* `/tiles/<game_title>` - renders all of the track tiles (and map hex "tiles")
  for the given game. Multiple game titles can be given, separated by `+`.
* `/tiles/<tile_name>` - renders a single tile at large scale (tile must be
  defined in `lib/engine/tile.rb`)
* `/tiles/<game_title>/<hex_coord_or_tile_name>` - renders a single hex or tile
  the given game at large scale. Multiple hex coords or tile names can be given,
  separated by `+`.

Optional URL params for above routes:

* `r=<rotation(s)>` - specify the rotation with an `Integer`, multiple rotations
    with `+`-separated `Integer`s, or `all` to see all 6. Preprinted tiles are
    not rotated. This param is ignored at `/tiles/all`.
* `n=<location_name>` - specify a location name to render for tiles that have at
    least one stop. Preprinted tiles with location names are not
    overridden. This param is ignored at `/tiles/all`.
* `grid` - show the triangular grid on the hexes to identify regions on the tile

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
