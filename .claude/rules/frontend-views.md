---
paths:
  - "assets/app/**/*.rb"
---

# Frontend views (`assets/app/`)

`assets/app/` is Ruby compiled to JavaScript by Opal and rendered with Snabberb
(a virtual-DOM library like React functional components). **It is Opal-only —
never write `if RUBY_ENGINE == 'opal'` here** (that branching belongs in shared
`lib/` code).

## Components

- A view is `class Foo < Snabberb::Component` with a `render` method returning
  **exactly one** `h(...)` node.
- To render nothing, `return ''` — **not `nil`** (`nil` breaks the patcher).
- **`h` has two call signatures:**
  - HTML tag: `h(selector, props = {}, children = nil)`. The selector string
    carries tag, id, and classes: `h('div#left.inline-block.right', props, kids)`.
  - Component: `h(SomeComponent, needs_hash)` — the hash is splatted into the
    constructor. Components take no children; an unknown key raises
    `"Unused needs passed to component"`.
- `require` every component you `h(...)`.

## `needs` and `store`

- `needs :x` — required; missing at construction raises.
- `needs :x, default: V` — optional.
- `needs :x, default: V, store: true` — reactive global state in the root store.
  **The store wins over a value passed as a prop** once the store key is set.
- Needs become `@x` automatically.
- Shared needs come from a mixin's `self.included(base)` hook: `include
  View::Game::Actionable` (gives `@game`, `@game_data`, `@user`,
  `process_action`, …) and/or `include Lib::Settings` (gives `color_for`). Don't
  re-declare those needs.
- `store(:k, v)` writes the store, sets `@k`, and schedules a full root
  re-render. `store(:k, v, skip: true)` writes without re-rendering. `store`
  **raises** unless `:k` is a `store: true` need of the current class. In async
  callbacks read the freshest state via bare `store` (returns the hash) — view
  instances are ephemeral.

## Opal / JavaScript

- Line 1: `# frozen_string_literal: true`.
- **`# backtick_javascript: true` on line 3 only if the file embeds JS via
  `` `...` `` or `%x{}`** — *not* for files that only use `Native(...)` /
  `.JS[...]`.
- Prefer `Native(`expr`)` / `.JS['prop']` for reading DOM/JS values; reserve
  backticks for statements.
- Known gotchas the codebase works around:
  - inside a raw-JS `setTimeout`, call `self['$store']('key', Opal.nil)` /
    `Opal.hash()` (the mangled Opal names);
  - force integer division with `.to_i` — `(degrees / 60).to_i`;
  - pass a Ruby hash to a browser API with `.to_n`;
  - URL params are strings — `Lib::Params['action']&.to_i`.

## Naming

Namespace mirrors the path under `assets/app/`: `view/game/foo.rb` →
`View::Game::Foo`; `lib/foo.rb` → `Lib::Foo`. Entry points (`App`, `Index`,
`GameManager`, `UserManager`) are deliberately un-namespaced.

## Styling

- Inline `style:` is a Ruby hash with **camelCase** keys and string values:
  `{ backgroundColor: color_for(:bg2), marginTop: '0.5rem' }`.
- Utility classes are baked into the selector string; the only stylesheet is the
  checked-in `public/assets/main.css` (no SCSS, no build step).
- **Never hard-code colors** — `include Lib::Settings` and use `color_for(:bg2)`
  / `color_for(:font2)`.
- Event handlers are lambdas under `on:`: `on: { click: -> (event) { ... } }`.
  For anchors that must not navigate, also set `attrs: { onclick: 'return false' }`.

## Game actions

Dispatch game actions **only** through
`process_action(Engine::Action::Foo.new(entity, **kwargs))` (from `Actionable`)
— never post to the server directly.
