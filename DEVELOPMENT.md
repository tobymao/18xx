# Development

See [`TILES.md`](/TILES.md) for some details and useful routes for tile
development.

See [Developing on Windows](https://github.com/tobymao/18xx/wiki/Developing-For-18xx.games#developing-on-windows) to get setup on Windows

## Use a Github Codespace

If you would like a repeatable build environment, click the `Code` button in the repo, click `Codespace` then the `plus sign` button to create [a new Codespace](https://github.com/features/codespaces).

![Screenshot 2022-11-13 10 09 46 AM](https://user-images.githubusercontent.com/1711810/201537600-294512b8-3a99-4762-8c16-d64294706434.png)

This will create a VM hosted by Github just for you with the repo already cloned and a generic Linux build environment installed.

> Note that Codespaces are limited to a monthly free usage quota

You are able to run `make` from the Terminal tab to build and start the 18xx server (based on the current branch checked out)

After the server is running, a pop-up in the bottom right should appear informing you that the server can be opened in a browser.

If that pop-up doesn't appear or if the url opens on a different port than `9292`, open the `Ports` tab in the Codespace, hover the "local address" for port `9292` and click the globe to open the server in a browser.

![image](https://user-images.githubusercontent.com/1711810/201538007-a5b4bf8a-9214-4ca3-a6a5-6304601c34c2.png)


## Droplet configuration

If configuring the droplet from scratch, these are the requirements:

- `docker`
- `docker compose`
- `make`
- this repo (via `git clone`)

## Docker

Start the Docker stack for this project:

```
make
```

To ensure a rebuild of one or more of the containers, this make task will add
`--build` to the `docker compose up` command that is run by the default task:

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
`docker compose up --build`:

```
make prod_deploy
```

- access the site at http://localhost:9292

Make code changes, and within a few seconds the app should restart. Manually
refresh your browser to load the new app.

> **_NOTE:_** for local development on Apple Silicon, use the
> `/Dockerfile.amd64` and `/db/Dockerfile.amd64` files by setting
> `DEV_DOCKERFILE=Dockerfile.amd64` whenever running `make` or `docker compose`
> commands, e.g., `DEV_DOCKERFILE=Dockerfile.amd64 make dev_up_b`. If you use
> Docker Desktop, enable `Use Rosetta for x86_64/amd64 emulation on Apple
> Silicon` in `Docker Desktop / Settings / General / Virtual Machine Options`.
> A tool like [direnv](https://direnv.net/) can be used so you can set up a
> `.envrc` file instead of manually setting `DEV_DOCKERFILE` every time you
> start work on the project.  You should also run `ln -s .rerun.amd64 .rerun`
> once.

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
CONTAINER_ID=$(docker ps --filter name="db.?1" --format '{{.ID}}')
docker cp db.backup.gz $CONTAINER_ID:/home/db
```

3. go to the container with `docker compose exec db bash`, then run these
   commands:

```
cd /home/db
gzip -f -k -d db.backup.gz
pg_restore -U root -d 18xx_development db.backup
```

#### Docker Documentation

https://docs.docker.com/get-started/

If `docker compose up` requires login, you probably need to create an access
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

#### How to troubleshoot a failing test

Let's say you got an error message like this:

```
Failures:

  1) Assets #html 18MEX 17849 renders endgame
     Failure/Error:
       MiniRacer::Context
         .new(snapshot: @snapshot)
         .eval(script, filename: @file)
```

1. Look for a file `17849.json` (in the spec folder)
2. Start a new game in the UI
3. Import a hotseat game
4. Copy the file content in the box and click `create`
5. Look for an error in the browser console

#### Running test fixtures

Run `docker compose exec rack rake` while a docker instance is running to run rubocop and test games. This ensures your changes don't break existing games, and that the code matches the project's style guide.

Run a specific set of test fixtures using the `-e` flag to `rspec`. This is useful when testing a specific bug or reproducing an issue.

`docker compose exec rack rspec spec/lib/engine/game/fixtures_spec.rb -e '<folder_name> <fixture_name>' [...]`

e.g. `docker compose exec rack rspec spec/lib/engine/game/fixtures_spec.rb -e '1860 19354'`

See also `public/fixtures/README.md` for more details on fixture tests and debugging.

#### Profiling the code

Run `docker compose exec rack rake stackprof[spec/fixtures/18_chesapeake/1277.json]` (or other file) to load and process the json file 1000 times. This will generate a stackprof.dump which can be further analyzed

```
stackprof --d3-flamegraph stackprof.dump >stackprof.html
stackprof stackprof.dump
```

#### Testing a Game Migration

Once a game has been made available on the website, bugs may be found where the solutions requires breaking active gamestates due to missing or added required actions. If the action is known to always need removal, or the additional action needed able to be determined computationally, we can automate this fix. This assumes you have a fixture/json file locally you want to fix.

1. Update `repair` within `scripts/migrate_game.rb` with the logic required to add/delete a step
2. Run `docker compose exec rack irb`
3. Execute `load "scripts/migrate_game.rb"`
4. Execute `migrate_json('your_json_file.json')`

This will apply the migrations to the game file you specified, allowing you to verify it worked as expected.

#### Loading a production game state to test locally

You may want example games in your development environment to test. One way to do this is to import games directly from the production website.

1. Run `docker compose exec rack irb`
2. Execute `load "scripts/import_game.rb"`
3. Execute `import_game(<product_game_id>)`

A copy of that game is now available locally. All accounts in the imported games will have their passwords scrubbed and will be assigned "password" as their new default one. You can use this to login as any active user in the game.

#### Pinning a game in your local test enviornment

You may want to pin a specific game in your local development environment. Pinning a game allows for breaking changes to be introduced while 'freezing' the existing game to a previous code commit version. Pinning is designed to work in production environments only, the following workaround can be applied to pin games in your local development environment.

1. Run `docker compose exec rack irb`
2. Import all the dependcies that will allow you to run `Game` class. Alternativly you can run `load "scripts/import_game.rb"`
3. Run `game = Game[id: <id of game you want to pin>]`
4. Run `game.settings['pin'] ='<sha of commit>'` . The sha should be of length 9 of the commit you want to pin to.
5. Run `game.save` to save the changes.

For the pin to work you need to generate the pin.js file. Doing so will break your development environment. Perform the following steps to generate the pin file and fix your development environment
1. Run `docker compose exec rack rake precompile`
2. Delete the contents of build folder
3. Restart your  development environment server

Note: The precompile step creates a <pinned sha>.js.gzip in public/pinned. If you're still seeing js errors unzip the compressed file. You can run `gzip -d <pin>.js.gz>` to extract the js file
