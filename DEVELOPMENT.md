# Development

## Requirements

* `docker`
* `docker-compose`
* `make`

## Anatomy of a Tile

![Anatomy of a Tile](/public/images/tile_anatomy.png?raw=true "Anatomy of a Tile")

## Docker

### Development

To develop with an environment more similar to production, use Swarm. (You will first need to run `docker swarm init`).

For an environment that gets started more quickly, use Compose.

In either case, when code changes are made, the rack is restarted, and after a
few seconds your changes should be visible in the browser with a refresh.

#### Swarm

First, build the `dev` Docker images:

```
make build
```

Then start the Docker stack in "development" mode:

```
make dev_up
```

After the first `make build`, you shouldn't need to rebuild the images if your
changes are limited to the code under `lib/`, but if you change stuff like
`Gemfile`, you'll need a rebuild.

* access the dev site at http://127.0.0.1:9292
* access Adminer (to manage the db) at http://127.0.0.1:8080/?pgsql=db&username=18xx&db=18xx_development

To bring down the stack:

```
make down
```

#### Compose

The above dev configuration uses docker swarm/stack. The biggest downside is
slow initialization time (though it provides nice features for zero-downtime
deployment).

These make tasks will manage the dev stack using compose:

```
make dev_up_c
```

```
make down_c
```

In this mode, the app can be reached at http://localhost:9292/

### Production

To build the images for production, all your changes must be committed or stashed. Then, run:

```
make build_prod
```

Images built with the above command will be tagged with the latest commit
SHA.

If an image is the same as a previously built image tagged with a diffrent
commit SHA, the new tag is not added. This means that the docker build cache had
every step of the build cached, meaning no changes for that image have been made
since the previous time it was built. By not adding a second commit tag, `docker
stack` is prevented from needlessly swapping identical containers.

To start the stack with production config and the latest production images that
have been built, run:

```
make prod_up
```
In production mode, after you make changes, you need to rebuild and deploy to
see the new changes running; just run `make prod_up` and `docker stack` and
wait.

* access the prod site at https://127.0.0.1

To bring down the stack:

```
make down
```

#### Deploying

This task simply SSHes to the production server (assuming you have the right SSH
configuration) and runs `git pull` and `make prod_up`:

```
make prod_deploy
```

Within a few minutes, the new version of the app should be live at
[18xx.games](https://www.18xx.games).

### Both modes

If you want to easily switch between "production" mode and "development" mode,
you can put dev environment variables in `.env_dev` and production variables in
`.env_prod`, and the scripts will manage `.env` as a symlink, pointing to the
file appropriate for the environment.

Similarly, if you have directories `db/data_dev` and `db/data_prod`, the scripts
will manage `db/data` as a symlink.
