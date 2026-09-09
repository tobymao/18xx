# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

18xx.games is an open-source web platform for playing 18xx board games. It runs on Ruby (Roda), uses PostgreSQL and Redis, and serves a frontend compiled from Ruby to JavaScript via Opal.

## Development Commands

All commands run inside Docker. Start the dev environment first:

```bash
make              # Start dev stack with rebuild (default)
make dev_up_b     # Same as above (explicit)
make dev_up       # Start without rebuild
```

Site is available at http://localhost:9292.

### Testing

```bash
# Run all tests (rubocop + fixture tests in parallel)
docker compose exec rack rake

# Run a specific fixture test
docker compose exec rack rspec spec/lib/engine/game/fixtures_spec.rb -e '1830 12345'
# Format: -e '<game_title> <fixture_id>'

# Run specs in parallel only
docker compose exec rack rake spec_parallel
```

### Linting / Formatting

```bash
docker compose exec rack rake rubocop               # Check formatting
docker compose exec rack bundle exec rubocop -A     # Auto-fix issues
make style                                          # Shorthand for rubocop -A
```

### Format fixture files

```bash
make fixture_format
```

### IRB / Debugging

```bash
docker compose exec rack irb
# Then: load "scripts/import_game.rb" to import a production game
# Or:   load "scripts/migrate_game.rb" then migrate_json('file.json') to repair a game
```

Use `debug!` (from `lib/engine/debug.rb`) to set breakpoints — works on both the Ruby (pry-byebug) and JavaScript (debugger statement) sides.

## Architecture

### Dual-environment Ruby

The engine code in `lib/engine/` runs in two environments:
- **Ruby** (server-side): standard Ruby execution for tests, API, game replay
- **JavaScript** (client-side): compiled from Ruby by [Opal](https://opalrb.com/) and served as JS

Code using `if RUBY_ENGINE == 'opal'` branches by environment. The `# backtick_javascript: true` comment enables JS-specific behavior.

### Core engine (`lib/engine/`)

Shared game logic:
- `game/base.rb` — Base class all games inherit from; handles loading games from JSON, game flow, and action replay
- `tile.rb`, `hex.rb`, `graph.rb` — Map and tile management
- `stock_market.rb`, `share_pool.rb` — Market mechanics
- `depot.rb`, `train.rb` — Train management
- `round/`, `step/` — Turn structure. A game plays a sequence of rounds (auction/draft, then alternating stock and operating rounds); `Game#next_round!` selects the next. Each round owns an ordered list of steps; a step handles one or more action types. The train *phase* (`phase.rb`) is separate — it only sets how many operating rounds run per set.

### Game implementations (`lib/engine/game/`)

~131 game titles. Each has a sibling stub file `g_XXXX.rb` (declares the empty `Engine::Game::GXXXX` module) plus a directory `g_XXXX/`:
- `meta.rb` — Game metadata: title, designer, publisher, player range, optional rules
- `game.rb` — Main class (extends `Game::Base`): constants (BANK_CASH, CERT_LIMIT, MARKET, etc.) and overrides
- `entities.rb` — Corporation and company definitions (omitted by variants that subclass another game's `Game`)
- `map.rb` — Hex map layout (likewise omitted by such variants)
- `step/`, `round/` — Any game-specific step/round overrides

### Frontend (`assets/app/`)

Ruby (compiled to JS by Opal):
- `view/` — Snabberb-based virtual DOM views (similar to React functional components)
- `game_manager.rb`, `user_manager.rb` — Client-side state management
- `app.rb` — Client entry point

### Tests (`spec/`)

- `spec/lib/engine/game/fixtures_spec.rb` — Automatically replays every JSON fixture in `public/fixtures/`. Fixtures are *required* to be `"status": "finished"` — a non-finished fixture fails the suite, it is not skipped.
- `spec/assets_spec.rb` — UI tests that assert DOM text using mini_racer to run the compiled JS.
- `public/fixtures/` — JSON game states. Adding a file here auto-includes it in tests.

### Backend

- `api.rb` — Roda API routes
- `models/` and `models.rb` — Sequel ORM models
- `routes/` — Additional route definitions
- `queue.rb` — Background job processing

## Adding or Modifying a Game

1. Create the stub file `lib/engine/game/g_XXXX.rb` (empty `Engine::Game::GXXXX` module) and the directory `lib/engine/game/g_XXXX/` with `meta.rb` and `game.rb` (plus `entities.rb` and `map.rb` for a standalone game)
2. No registration step — games are auto-discovered by reflecting over `Engine::Game` constants (do not edit `lib/engine.rb`)
3. Add a fixture JSON under `public/fixtures/`. The directory name is the title with all non-alphanumeric characters removed (e.g. `18462pVariant`); confirm with `Engine.meta_by_title('<title>').fixture_dir_name`
4. The fixture must have `"status": "finished"`, `"loaded": true`, and a `"result"` key; run `make fixture_format` before committing it

## Useful Dev Routes

When the server is running:
- `/map/<game_title>` — View a game's map
- `/tiles/all` — All track tiles
- `/tiles/<game_title>/all` — All tiles for a specific game
- `/tiles/<game_title>/<hex_coord>` — Single hex at large scale
