# App

## Development

### Anatomy of a Tile

![Anatomy of a Tile](/public/images/tile_anatomy.png?raw=true "Anatomy of a Tile")

### Docker

https://docs.docker.com/get-started/

Create an access token and login with the Docker CLI:

* https://docs.docker.com/docker-hub/access-tokens/
* https://docs.docker.com/engine/reference/commandline/login/

Build and start the Docker stack for this project:

```
docker-compose up --build
```

* access the site at http://localhost:9292/
* access Adminer at http://localhost:8080/?pgsql=postgres&username=root&db=db_18xx

Make code changes, and within a few seconds the app should restart. Manually
refresh your browser to load the new app.
