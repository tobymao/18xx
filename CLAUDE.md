# CLAUDE.md — 18xx.games

Open-source web app for playing [18xx](https://boardgamegeek.com/boardgamefamily/19/series-18xx)
board games. Fork of [tobymao/18xx](https://github.com/tobymao/18xx), runs at
[18xx.games](https://18xx.games).

## Stack

- **Language: Ruby 3.2** — the whole app, front and back, is Ruby.
- **Backend:** [Roda](https://roda.jeremyevans.net/) (web framework) · [Sequel](https://sequel.jeremyevans.net/)
  ORM over **PostgreSQL** · **Redis** (via `message_bus` for pub/sub) · **Unicorn** app server.
- **Frontend:** [Opal](https://opalrb.com/) compiles Ruby → JavaScript, and
  [Snabberb](https://github.com/mrmr1993/snabberb) is a Ruby virtual-DOM component
  framework. **The UI is written in Ruby** (`assets/app/`), not JS. `esbuild` bundles deps.
- **JS interop:** occasional inline JS via backticks in files marked `# backtick_javascript: true`.
- **Server-side JS eval:** `mini_racer` runs the Opal-compiled bundle in tests (asset rendering).
- **Style/CI:** RuboCop (`.rubocop.yml`); RSpec for tests.

## Layout

- `lib/engine/` — the **game engine**, pure Ruby, shared by both server and Opal frontend.
  Core primitives: `corporation.rb`, `share.rb`, `train.rb`, `tile.rb`, `route.rb`,
  `stock_market.rb`, `depot.rb`, `phase.rb`, plus `step/` and `round/` (shared game-flow logic).
- `lib/engine/game/g_<title>/` — one module per game (**~260 games**). Each has:
  - `meta.rb` — `Meta` mixin: player range, designer, `DEV_STAGE`, `OPTIONAL_RULES`, etc.
  - `game.rb` — `Game < Game::Base`, `include`s Meta/Entities/Map; rules as constants
    (`BANK_CASH`, `CERT_LIMIT`, `MARKET`, `STARTING_CASH`, `TRACK_RESTRICTION`, …).
  - `entities.rb` — companies/corporations/minors. `map.rb` — hexes, tiles, locations.
  - `step/`, `round/` — game-specific overrides subclassing the shared `Engine::Step::*` /
    `Engine::Round::*` classes.
- `assets/app/` — Opal/Snabberb frontend (`view/`, `lib/`, `game_manager.rb`, etc.).
- `models/`, `routes/`, `api.rb`, `config.ru` — Sequel models and Roda routes for the server.
- `spec/` — RSpec. `public/fixtures/` — recorded games replayed as regression tests.
- `db/`, `redis/`, `nginx/` — per-service Docker build contexts.

## Build & run (Docker; images already built)

Default stack is dev. The `docker-compose.override.yml -> docker-compose.dev.yml` and
`.rerun -> .rerun.amd64` symlinks are already in place (this host uses the **amd64** path).

```bash
docker compose up -d          # start stack detached
# site: http://localhost:9292   (code changes hot-reload via rerun; refresh browser)
docker compose logs rack -f    # tail app logs
docker compose down            # stop
```

`make` (default `dev_up_b`) runs `docker compose up --build` in the foreground — use it when
you need to rebuild an image. On Apple Silicon set `DEV_DOCKERFILE=Dockerfile.amd64`.

## Test & lint

```bash
docker compose exec rack rake                      # rubocop + all game fixture tests (the full suite)
docker compose exec rack rspec spec/lib/engine/game/fixtures_spec.rb -e '1860 19354'  # one fixture
docker compose exec rack rake rubocop              # lint only
docker compose exec rack bundle exec rubocop -A    # auto-fix lint
```

Fixtures are the primary regression safety net: a change must not break replay of existing
recorded games. See `public/fixtures/README.md` for fixture debugging.

## Working on a game (the common task)

Adding/fixing a game = editing its `g_<title>/` module. Subclass shared engine classes and
override; express rules as constants where the base class reads them. Match RuboCop style
(the base classes and neighboring games are the reference). Verify with the fixture suite.

## Skills to lean on here

Ruby (fluent — it's everything) · the shared engine's step/round/entity model · Opal's
Ruby-subset constraints + Snabberb components for UI work · Sequel/Roda for server/models/routes ·
18xx domain fluency (shares, trains, tiles, routes, tokens, phases, stock market) · fixture-based
testing · RuboCop compliance.
