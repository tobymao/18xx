# Game-specific setup directives (setup extensions)

The "god-move" **setup** action (`Engine::Action::Setup`, applied by the
non-blocking `Engine::Step::Setup`) builds a preset game position without playing
through the normal steps. It carries a fixed set of generic directive keys that
work across every title:

`cash`, `phase`, `rust`, `par`, `market`, `shares`, `trains`, `tiles`,
`remove_tiles`, `tokens`, `companies`, `loans`, `advance`.

Those cover the fundamentals. Some titles have mechanics the generic keys can't
express — 1880's building permits and par-location floating, foreign investors,
prototype-specific bookkeeping, and so on. Rather than bloat the shared action
with per-game fields, setup carries one open-ended key, **`extensions`**, that
delegates to a per-game hook.

## The seam

`extensions` is a hash of `{ "directive_key" => payload }`. For each entry,
`Step::Setup#process_extensions` calls:

```ruby
game.process_setup_extension(step, key, payload)
```

`Game::Base#process_setup_extension` raises by default (unknown directive for
this title). A title opts in by overriding it in its `g_<title>` module.

## Writing a handler

Override `process_setup_extension` in the game class and mutate state directly —
the whole point of a god-move is to bypass normal legality. The `step` argument
exposes the same id lookups the generic handlers use, with coercion and friendly
errors:

- `step.corporation!(id)`
- `step.player!(id)` (accepts integer or numeric-string ids)
- `step.company!(id)`
- `step.hex!(id)`
- `step.corp_or_player!(id)` (private companies can be owned by either)

```ruby
module Engine
  module Game
    module G1880
      class Game < Base
        # extensions: { "building_permit" => { "corporation" => "AB", "permit" => "BCR" } }
        def process_setup_extension(step, key, payload)
          case key
          when 'building_permit'
            corp = step.corporation!(payload['corporation'])
            corp.building_permit = payload['permit']
          else
            super
          end
        end
      end
    end
  end
end
```

Always call `super` in the `else` branch so unrecognized keys still raise a clear
error.

## Emitting an extension directive

From Ruby (or a test), build a setup action with the `extensions` field:

```ruby
Engine::Action::Setup.new(
  game.current_entity,
  extensions: { 'building_permit' => { 'corporation' => 'AB', 'permit' => 'BCR' } },
)
```

Like every other setup directive, `extensions` is additive to the action log, so
it serializes, round-trips through JSON, replays deterministically, and is
delivered through the normal import-hotseat path.

## Notes

- Extensions run after all generic directives and before `advance`, so the
  position (par, tokens, tiles, etc.) is already in place when your handler runs.
- Keep handlers to plain Ruby that compiles under Opal (the frontend runs the
  engine compiled to JS); avoid MRI-only constructs.
- Prefer reusing the game's own high-level methods (float, buy, place) over
  hand-rolling mutations, so derived inventory (share pool, depot, routing graph)
  stays consistent.
