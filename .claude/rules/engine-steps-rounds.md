---
paths:
  - "lib/engine/step/**/*.rb"
  - "lib/engine/round/**/*.rb"
  - "lib/engine/action/**/*.rb"
  - "lib/engine/game/*/step/**/*.rb"
  - "lib/engine/game/*/round/**/*.rb"
---

# Turn structure: rounds and steps

A game plays a sequence of rounds (an auction/draft, then alternating stock and
operating rounds); `Game#next_round!` picks the next one. Each round owns an
ordered list of steps; a step handles one or more action types. The train
*phase* (`Engine::Phase`) is a separate concept — it only controls how many
operating rounds run per set and which trains/tile colors are available.

## Action dispatch

`Round::Base#process_action` (`round/base.rb:112-124`) scans active steps in
order and stops at the first one that either can process `action.type` (its
**`actions(entity)`** array includes it) or is currently `blocking?`. **A
blocking step that can't process the action raises immediately** ("Blocking
step X cannot process action Y") rather than letting a later step try — this
is the most common `GameError` message from a malformed or out-of-order
action. Once a step is found, dispatch calls `step.send("process_#{action.type}", action)`.

`action.type` is the action class's base name de-camelized (`Helper::Type`):
`Engine::Action::BuyTrain` → `"buy_train"` → `process_buy_train`. Handling a new
action type means adding a `process_<snake_case>` method to a step.

## Writing a step

- **`actions(entity)` is the contract, not the `ACTIONS` constant.**
  `Step::Base#actions` returns `[]` and does **not** fall back to
  `self.class::ACTIONS`. A step that declares `ACTIONS` but never defines
  `actions` will never fire. Steps that use the constant reference it themselves
  — prefer `self.class::ACTIONS` so subclasses can override it.
- Convention for `actions`: guard first
  (`return [] unless entity == current_entity`, `return [] if entity.company?`),
  build the array, then append `'pass'` **last and only when the array is
  otherwise non-empty**.
- **`blocks?` vs `blocking?`:** `blocks?` (default `true`) is the static "can this
  step halt the round?"; `blocking?` is `blocks? && !current_actions.empty?` and
  is what the round actually checks. Override `blocks?`, never `blocking?`.
- **`skip!`** defaults to `pass!` and must never raise — it is the "no eligible
  action" path. Override it to push a synthetic action into history (see
  `step/dividend.rb`).
- Overriding `pass!`, `unpass!`, or `setup` → **always call `super`**.
- **`setup` runs on every entity change**, not once (`round/operating.rb:76-79`)
  — it is the per-turn reset hook. One-time round setup goes in the `Round`
  subclass's `setup` / `after_setup`.
- Every step gets `@game`, `@log`, `@round`, `@opts`. Reach engine services and
  rule constants through `@game`: `@game.class::EBUY_FROM_OTHERS`,
  `@game.stock_market`, `@game.format_currency(...)`. Log with `@log << "..."`;
  player-directed lines via `@game.player_log(entity, msg)`.

## Round-shared state

A step declares shared state by returning a hash from `round_state`.
`Round::Base#initialize` records each key and sets it as a **bare instance
variable on the round instance**. Steps read/write it as `@round.foo` — served by
`method_missing`, with **no accessor methods** by design (a YJIT memory-leak fix;
see the comment at `round/base.rb:44-57`). Round *subclasses* use `@foo`
directly. Two steps declaring the same key silently collide.

Round lifecycle hooks: `setup`, `after_setup`, `before_process`,
`after_process_before_skip`, `after_process`. A round subclass overriding
`after_process` or `setup` must call `super` or entity advancement breaks.

## Game wiring

- There is **no `OPERATING_STEPS` / `STOCK_STEPS` constant.** Override
  `operating_round(round_num)` / `stock_round` in `game.rb` to return
  `Round::Operating.new(self, [ ...step list... ], round_num: round_num)`.
- `Round::Base::DEFAULT_STEPS` (`EndGame`, `Message`, `Program`) is always
  prepended — games supply only the tail.
- Step-list entries are a bare `StepClass` or `[StepClass, { opts }]` (only a
  flat 2-tuple is supported; opts are read as `@opts` in the step).
- `init_round` returns the first round. To add a round type, override
  `init_round` **and** `next_round!` (a `case` on the current round's class —
  `return super` for the common path), and often `round_end`.

## Game-specific step/round subclass

```ruby
# lib/engine/game/g_1846/step/buy_train.rb
# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1846
      module Step
        class BuyTrain < Engine::Step::BuyTrain
```

- Same leaf name as the parent; file mirrors the engine path.
- `require_relative` climbs three levels to `lib/engine/step/` (or
  `lib/engine/round/`).
- In `game.rb`, reference it as `G1846::Step::BuyTrain`. A bare `Step::Foo` /
  `Round::Foo` resolves game-module-first, then `Engine::` — so a game with no
  local `round/` gets `Engine::Round::Stock` from a bare `Round::Stock`.
- Explicitly `require_relative` each local `step/` and `round/` file from
  `game.rb` (Opal `require_tree` ordering).

## Environment

Line 1 of every file is `# frozen_string_literal: true`. Individual step/round
files need only `require_relative 'base'` and are auto-loaded — no Opal branch at
file level.
