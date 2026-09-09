---
paths:
  - "spec/**/*.rb"
---

# Specs

RSpec runs **`--order defined`** (`.rspec`) — examples execute top-to-bottom,
never randomized. Don't rely on random-order isolation; *do* rely on ascending
order (the fixture cache only replays forward). Default task is
`docker compose exec rack rake` (rubocop + `spec_parallel`).

For fixture files themselves, see [[fixtures]].

## Hand-written game specs

Live at `spec/lib/engine/game/<fs_name>/game_spec.rb` (`g_1889/`,
`g_18_chesapeake/`; a couple of older dirs drop the `g_` prefix — the directory
name is cosmetic, discovery is by the `*_spec.rb` glob).

- **The top-level `describe` must be the Game class constant** —
  `describe Engine::Game::G1846::Game do` — because `spec/fixture_cache.rb` does
  `Object.const_get(<that string>).title`. Not a string, not the `Meta` module.
- When a test calls `fixture_at_action(n)`, **some enclosing `describe`/`context`
  name must exactly equal a fixture filename** (minus `.json`) in that game's
  `fixture_dir_name` directory.
- `fixture_at_action(n)` reuses one cached game per fixture and only moves
  forward. **Pass `fixture_at_action(n, clear_cache: true)` in any test that
  processes its own actions** (anything not already in the fixture) — otherwise
  the mutated game leaks into the next `it`.
- There is **no `shared_examples` and no shared `Helper` module** in game specs —
  define per-file helper methods inside the top `describe` block (the established
  pattern).
- Fixture-free alternative: `game = Engine::Game::G1835::Game.new(players)`, then
  drive it with `game.process_action(Engine::Action::X.new(...)).maybe_raise!`.

Custom matchers in `spec/matchers.rb`: `be_assigned_to`, `have_available_hexes`.

## `spec/assets_spec.rb`

The only UI test — it runs the Opal-compiled JS through `MiniRacer` and asserts
on raw HTML text. Add a regression case by appending a row to `TEST_CASES`
referencing an existing fixture. A `!!`-prefixed expected string asserts
*absence*. Match against HTML entities (`B&amp;amp;O`, not `B&amp;O`).
