# AGENTS.md

Guidance for coding agents working on [18xx.games](https://18xx.games). Read this before changing code.

Related docs:

- [`DEVELOPMENT.md`](DEVELOPMENT.md): Docker setup, database, debugging, profiling, game migrations, importing production games, pinning
- [`public/fixtures/README.md`](public/fixtures/README.md): fixture tests and debugging game state from fixtures
- [`TILES.md`](TILES.md): tile development and useful tile routes
- [`lib/engine/GRAPH.md`](lib/engine/GRAPH.md): the route/connectivity graph
- [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md): PR checklist
- [Developing for 18xx.games](https://github.com/tobymao/18xx/wiki/Developing-for-18xx.games) (wiki): adding games,
  advice, troubleshooting. Pre-alpha titles only appear on the new game page with `?all` in the URL
  (e.g. `http://localhost:9292/new_game?all`).
- [Developing FAQ](https://github.com/tobymao/18xx/wiki/Developing-FAQ) (wiki): running specs by line number or
  `--only-failures`, running rubocop on specific files
- [Common Rule Interpretations](https://github.com/tobymao/18xx/wiki/Common-Rule-Interpretations) (wiki): rulings
  that apply across titles when the rules are ambiguous

## How it works

- **One engine, two runtimes.** `lib/engine` runs as MRI Ruby on the server and in specs, and is compiled to
  JavaScript by [Opal](https://opalrb.com/) to run in the browser. Code must behave the same in both (see
  [Ruby that runs in the browser](#ruby-that-runs-in-the-browser)).
- **A game is a seed plus a list of actions.** Every load builds a fresh `Game` and replays all actions from the
  start. Any change that alters the outcome of a past action, or which actions are legal or required, breaks games
  in progress (see [Breaking live games](#breaking-live-games)). This is also why fixtures work as tests.
- **Game.** Each title lives in `lib/engine/game/g_<title>/`:
  - `meta.rb`: title, designer, player counts, optional rules
  - `entities.rb`: companies, corporations, minors
  - `map.rb`: hexes, tiles, location names
  - `game.rb`: `class Game < Game::Base` (or a subclass of another title's `Game`, e.g. the 1822 and 1867 families)
  - `round/`, `step/`: title-specific subclasses of the core rounds and steps

  `Game::Base#next_round!` drives the sequence: `init_round` (usually an auction), then `stock_round`, then
  `operating_round` as many times as the current phase allows, then back to stock. A title chooses which steps each
  round runs by overriding `stock_round`, `operating_round` or `init_round`. Train purchases advance the phase, and
  phase changes fire `event_<name>!` methods on the game.
- **Round** (`lib/engine/round/`). Holds an ordered list of steps and decides which entities act and in what order.
  `Round#process_action` gives each action to the first active step that lists its type in `actions(entity)`; a
  blocking step that can't process the action raises instead of letting a later step take it. When the round is
  `finished?`, the game moves to the next round.
- **Step** (`lib/engine/step/`). Declares the action types an entity may take with `actions(entity)`, handles each in
  `process_<type>`, and ends with `pass!`. Steps with nothing to do are skipped automatically. Most title-specific
  rules are a subclassed step or a game method that a step calls.
- **UI** (`assets/app/view`). Opal + [Snabberb](https://github.com/tobymao/snabberb) components read
  `round.active_step` and `round.actions_for(entity)` to decide which buttons, hexes and inputs to show. Clicking one
  submits an action.
- **Server.** Roda, Postgres and Redis (`api.rb`, `models/`, `routes/`). Game work rarely touches it; see
  `DEVELOPMENT.md`.

## Running things

`DEVELOPMENT.md` assumes Docker. If Docker isn't available, run the same tools directly after `bundle install`.

| Task | Docker | Without Docker |
| --- | --- | --- |
| Full suite (compile, specs, rubocop) | `docker compose exec rack rake` | `bundle exec rake` |
| One spec file | `docker compose exec rack rspec <path>` | `bundle exec rspec <path>` |
| One title's fixtures | `docker compose exec rack rspec spec/lib/engine/game/fixtures_spec.rb -e '<title>'` | `bundle exec rspec spec/lib/engine/game/fixtures_spec.rb -e '<title>'` |
| One fixture | `... -e '<title> <fixture id>'` | `... -e '<title> <fixture id>'` |
| Lint and autocorrect | `docker compose exec rack rubocop -a` | `bundle exec rubocop -a` |

To inspect engine state without the web server:

```sh
bundle exec ruby -e "require './lib/engine'; g = Engine::Game::G1889::Game.new(%w[a b c], seed: 1); p g.round.active_step"
```

To check the UI without a browser, render a page headlessly the way `spec/assets_spec.rb` does:
`Assets.new.html('assets/app/app.rb', app_route: "/game/#{data['id']}", game_data: data,
user: data['user'].merge(settings: { consent: true }))`, then search the HTML for the text you expect (or for errors
such as "cannot be continued"). Without `consent` the page renders the privacy-policy prompt instead of the game.

## Ruby that runs in the browser

MRI specs pass even when the browser breaks, so follow these rules in `lib/engine` and `assets/app`:

- **Integer division.** In Opal, `Integer#/` is JavaScript float division (`7 / 2 == 3.5`). Write
  `(numerator.to_f / divisor).floor` or `(numerator.to_f / divisor).ceil`, whichever the rules require, wherever an
  integer result matters. Don't use `.round`.
- **Emptiness checks.** Prefer `!array.empty?` over `array.any?`; `empty?` is much cheaper.

When a change affects what the UI renders, render the page headlessly (above) at a state that exercises it.

## Writing game code

- **Follow the rulebook.** Every rule the code enforces should trace back to the title's rules; don't invent
  behavior, and cite the rule in the PR when it isn't obvious. Check that the change still works with each optional
  rule in the title's `meta.rb`. When the rules are ambiguous, follow
  [Common Rule Interpretations](https://github.com/tobymao/18xx/wiki/Common-Rule-Interpretations).
- **Use what the engine already has.** Before writing custom code, look for an existing mechanism: company powers
  belong in abilities (`lib/engine/ability/`) rather than special cases in the game class, and existing helpers on
  the game, depot and core steps (or a hook such as `can_buy_train?` that a step already calls) usually beat
  reimplementing their logic.
- **No magic strings, no redundant constants.** Put fixed names and values in constants (`map.rb` and
  `entities.rb` hold only constants) and read them through a method so titles that inherit from this one can
  override them:

  ```ruby
  def minor_count
    self.class::MINOR_COUNT
  end
  ```

  Don't add constants for data already on the entities or map: derive it instead (a tile's color, a corporation's
  home hex, a name written directly in the company definition).
- **Use one name for each concept.** Use the rulebook's term and the same name across code, logs and UI (don't call
  one thing `union_pacific` in one place and `national` in another). Group multi-step setup into `setup_<thing>`
  helpers called from `setup`.
- **Don't add code comments.** Make the code clear through naming and structure instead.
- **Keep display in the views.** The engine exposes game state and data (e.g. a game method that returns a status
  string); views in `assets/app/view` decide layout, widths and formatting. Don't put layout concerns in
  `lib/engine` or game rules in views.
- **Keep it simple.** Prefer the simplest solution that matches the rules. If a mechanic needs many special cases,
  look for a new abstraction that removes them.
- **Avoid duplication.** Before implementing a mechanic, search other titles for the same or a similar one. If it
  exists, generalize it and share it rather than copying it.
- **Check the blast radius of shared code.** When changing core engine code or code another title uses, find every
  title that depends on it (search for the method or module name, and for titles whose `Game` subclasses the one you
  changed), then run those titles' specs and fixtures. Tag the PR `[core]` when touching shared `lib/engine` code.

## Tests

- Write specs for every change, including UI changes. Trivial constant or flag fixes may skip specs at the author's
  discretion.
- Title specs live in `spec/lib/engine/game/g_<title>/`. View specs live in `spec/assets/app/view/`, and rendered-page
  assertions against fixtures go in `spec/assets_spec.rb`.
- Fixtures live in `public/fixtures/<fixture dir>/` (`spec/fixtures` is a symlink) and run automatically in
  `spec/lib/engine/game/fixtures_spec.rb`. See `public/fixtures/README.md` for the required fields and formatting
  (`make fixture_format`).

## Investigating a reported game

1. **Get the game's JSON** from `/api/game/<id>` (see [Using the live site](#using-the-live-site-18xxgames)), or from
   the game's Tools tab for hotseat games.
2. **Replay it locally.** `Engine::Game.load('game.json', at_action: n)` rebuilds the game up to action `n`; check
   `game.exception` and `game.log` for the failure. Write a short repro script that loads the state just before the
   broken action, inspects it, and processes the action.
3. **Fix it, then keep the repro as a test**: a spec that loads the JSON at that action and asserts the corrected
   behavior, or the game as a fixture.
4. **Check whether the fix changes past actions' outcomes** (see [Breaking live games](#breaking-live-games)).

## Validating a shared-code change

Fixture specs only check each game's final result. When changing shared code, especially performance work, also
compare intermediate state: replay the affected titles' fixtures (and imported games if needed) on `master` and on
your branch, dump the state the change touches after each action (e.g. graph output, routes, log), and diff the two
runs. Any difference must be intended.

## Simulating games through the UI

When building a new title or testing a large change, play complete games using only actions the UI would offer.
Engine-only specs can't catch actions the engine accepts but the UI never shows, or states the UI can't get out of.

1. **Enumerate UI options.** Write a helper that, for the current game state, mirrors the views
   (`assets/app/view/game_page.rb` and the round, map and train views under `assets/app/view/game/`) and returns exactly the
   actions their buttons, hexes and inputs would submit.
2. **Play with a seeded bot.** Repeatedly pick one of those options at random (weighted by a profile such as
   aggressive or conservative), process it, and continue until the game ends. Seed both the game and the bot so runs
   are reproducible. Stop and report when no option is offered or every option is rejected.
3. **Verify.** Replay saved games and assert every action was one the UI offered at that point.
4. **Keep useful games as fixtures.** Exported games can become fixtures that cover the paths the bot exercised.

Run several games in parallel in the background; a full game can take minutes. The bot can't press Undo, so it can
stall on flows that expect the player to undo; treat those as limits of the bot, not engine bugs, after checking.

## Breaking live games

If a change alters the outcome of a past action, or which actions are legal or required, games in progress on the
site will break when replayed. In that case:

- Try to repair the affected games with a migration script first. Copy `scripts/migrate_game.rb` to
  `scripts/migrate_<title>_<change>.rb`, keep its reading and writing of games (`migrate_json`,
  `migrate_db_actions`, `migrate_title`, etc.) as is, and change only the `repair` section. Test it against fixtures
  or imported games with `migrate_json` (see "Testing a Game Migration" in `DEVELOPMENT.md`). Migration scripts are
  one-off: delete them once they have run in production, and don't use existing ones as templates.
- If a migration isn't possible, that's fine: the affected games get pinned to the previous code instead.

Label the PR so maintainers know what the release needs:

- `migration` if a migration script is needed.
- `pins` if a migration isn't possible and some games will break.
- `archive_alpha_games` if the broken games are of a title in alpha.

With any of these, also add the label for each affected title (e.g. `1889`, `18Chesapeake`) so the deployer knows
which games to migrate, pin or archive. If a title has no label yet, name the titles in the PR description.

## Using the live site (18xx.games)

- Make **at most one request per second** to the site or its API, or the site will block your IP. Run requests
  sequentially with `sleep 2` between them; never in parallel.
- Fetch only what you need: `/api/game?title=<title>&finished=<n>` lists games, and `/api/game/<id>` returns a
  game's full JSON. `scripts/import_game.rb` copies a production game into the local database (see
  `DEVELOPMENT.md`).

## Pull requests

- Branch from the latest `master`.
- Start the title with the affected title(s), e.g. `[1889] ...`; add `[core]` for shared `lib/engine` changes and
  `[dev]` for developer-only changes.
- Split new titles into several reviewable PRs.
- Add the `migration`, `pins` or `archive_alpha_games` label, plus each affected title's label, when the change
  breaks live games (see [Breaking live games](#breaking-live-games)).
- Run rubocop and the full suite before opening the PR, and fill in the PR template.
- In the description, say what you verified (specs, fixtures, reproduced games) and what you didn't run, and why
  the change does or doesn't need pins or a migration.

### Addressing review feedback

- When a reviewer gives specific code, use it as given. If you think it's wrong, say so and explain why instead of
  quietly writing something different.
- Change only what the feedback asks for. Don't refactor, merge or extend nearby code beyond the request.
