---
paths:
  - "lib/engine/game/**/*.rb"
---

# Game implementations (`lib/engine/game/`)

Each of the ~131 game titles lives in `lib/engine/game/g_<name>/`. See `TILES.md`
for the tile-definition string syntax used in `map.rb`.

## Adding a game = 5 files, not 4

1. **`lib/engine/game/g_<name>.rb`** — the sibling stub. Just declares the empty
   module namespace; universal across every game, easy to forget, not mentioned
   in CLAUDE.md:

   ```ruby
   # frozen_string_literal: true

   module Engine
     module Game
       module G18Chesapeake
       end
     end
   end
   ```

2. **`g_<name>/meta.rb`** and 3. **`g_<name>/game.rb`** — always.
4. **`g_<name>/entities.rb`** and 5. **`g_<name>/map.rb`** — for a standalone
   game. A variant whose `game.rb` subclasses another game's `Game` class
   (`GAME_IS_VARIANT_OF`) usually inherits or inlines these and omits the files.

**There is no registration step — do not edit `lib/engine.rb`.** Games are
discovered by reflecting over `Engine::Game.constants` (`lib/engine.rb:18-23`) and
by globbing `lib/engine/game/*/game.rb` for the JS builds (`lib/assets.rb`). A
game exists once `Engine::Game::G<Name>::Meta` and `::Game` are defined under
`lib/engine/game/`.

## Directory ↔ module name

There is no reliable mechanical transform from directory to module name.
`Meta::ClassMethods#fs_name` in `lib/engine/game/meta.rb` gives the forward
direction (module → directory: `G` → `g_`, underscore before each run of
capitals, downcase), but it's lossy going back — acronyms and state/country
codes stay all-caps rather than title-case, so `g_18_va` → `G18VA` (not
`G18Va`), `g_18_mex` → `G18MEX`, `g_1817_na` → `G1817NA`. **Don't derive the
module name — read the sibling stub file (`g_<name>.rb`) or `git grep` it.**

| directory | module |
| --- | --- |
| `g_1830` | `G1830` |
| `g_18_chesapeake` | `G18Chesapeake` |
| `g_18_va` | `G18VA` |

## `meta.rb`

```ruby
# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1830
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        # ...bare constants...
      end
    end
  end
end
```

- `require_relative '../meta'` and `include Game::Meta` are both mandatory.
- De-facto required constants: `DEV_STAGE`, `GAME_DESIGNER`, `GAME_INFO_URL`,
  `GAME_LOCATION`, `GAME_PUBLISHER`, `GAME_RULES_URL`, `PLAYER_RANGE`.
- `PLAYER_RANGE` is a frozen 2-element `[min, max]` array — a missing one raises
  `NoMethodError` on `nil`.
- **`DEV_STAGE` values are `:production`, `:beta`, `:alpha`, `:prealpha`** (see
  `Meta::DEV_STAGES`). There is **no `:prototype`** — prototype-ness is a
  separate boolean constant `PROTOTYPE`. New games start at `:prealpha`; only
  `:alpha`/`:beta`/`:production` are visible in the UI.
- `GAME_PUBLISHER` is a symbol, or array of symbols, keyed into
  `Engine::Publisher::INFO` (e.g. `:lookout`, `%i[gmt_games golden_spike]`).
- `OPTIONAL_RULES` entries: `{ sym:, short_name:, desc: }` (optional `players:`).
- `GAME_VARIANTS` entries: `{ sym:, name:, title:, desc: }` where `title:` is
  another game's title.

## `game.rb`

Require order matters — **`require_relative '../base'` comes last**:

```ruby
# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'step/special_track'   # each local step/ and round/ file
require_relative '../company_price_up_to_face'   # shared mixins live one level up
require_relative '../base'               # ALWAYS LAST

module Engine
  module Game
    module G1830
      class Game < Game::Base
        include_meta(G1830::Meta)
        include Entities
        include Map
        # ...
```

- `include_meta(G<Name>::Meta)` copies every constant from the `Meta` module onto
  the `Game` class, so `DEV_STAGE`, `PLAYER_RANGE`, etc. are also available there.
- Game rules are expressed as **constants overriding `Game::Base` defaults**:
  `BANK_CASH`, `CERT_LIMIT`, `STARTING_CASH`, `CAPITALIZATION`, `MARKET`,
  `PHASES`, `TRAINS`, `CURRENCY_FORMAT_STR`, `TRACK_RESTRICTION`,
  `SELL_BUY_ORDER`, … Per-player-count values are hashes keyed by player count.
  `.freeze` every large literal. Extend an inherited hash with `.merge`, e.g.
  `STATUS_TEXT = Base::STATUS_TEXT.merge(...).freeze`.
- Behaviour tweaks are Ruby method overrides that call `super`.

## `entities.rb` / `map.rb`

Pure data modules — module name is **exactly** `Entities` / `Map`, no `require`,
no `include`, no methods, just constants:

- `Entities`: `COMPANIES`, `CORPORATIONS`, optional `MINORS` (arrays of hashes).
- `Map`: `TILES` (id → count), `LOCATION_NAMES` (hex-coord → string), `HEXES`
  (keyed by color `:white`/`:yellow`/`:red`/`:gray`), `LAYOUT` (`:pointy` or
  `:flat`).

Mixed into the game class with `include Entities` / `include Map`.

## Environment

- Line 1 of every file is `# frozen_string_literal: true`.
- **Do not** add `if RUBY_ENGINE == 'opal'` branches or a
  `# backtick_javascript: true` comment to game files — only
  `lib/engine/game/base.rb` needs those.

## Game-specific `step/` and `round/`

See [[engine-steps-rounds]].
