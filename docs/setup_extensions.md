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

## Offering game-gated tiles in map-edit mode

The Setup Editor's map-click mode builds its tile candidates from
`all_potential_upgrades`, which runs the game's `upgrades_to?`. If a title gates a
tile behind ownership or economics (e.g. 1871's `9` straight requires the SBC
private), that tile never appears in the god-move selector even though a god-move
should ignore the restriction — and the engine `tiles` directive would happily lay
it (it bypasses `upgrades_to?`).

Override `Game::Base#setup_edit_extra_tiles(hex)` to add such tiles back into the
map-edit selector. Return `Tile` objects; the editor matches them by name against
the unlaid pool and marks all rotations legal.

```ruby
# g_1871/game.rb — the '9' straight is SBC-gated in play; surface it in setup.
def setup_edit_extra_tiles(hex)
  return [] unless hex.tile.color == :white

  @all_tiles.select { |t| t.name == '9' }.uniq(&:name)
end
```

This is a separate seam from `process_setup_extension`: that one *applies* setup
directives at replay time, while this one only *offers* tiles in the authoring UI.
The tile still lays through the ordinary `tiles` directive.

## Notes

- Extensions run after all generic directives and before `advance`, so the
  position (par, tokens, tiles, etc.) is already in place when your handler runs.
- Keep handlers to plain Ruby that compiles under Opal (the frontend runs the
  engine compiled to JS); avoid MRI-only constructs.
- Prefer reusing the game's own high-level methods (float, buy, place) over
  hand-rolling mutations, so derived inventory (share pool, depot, routing graph)
  stays consistent.
