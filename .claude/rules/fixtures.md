---
paths:
  - "public/fixtures/**/*.json"
---

# Game fixtures (`public/fixtures/`)

Fixtures are JSON snapshots of played-out games (exported from a game's "Tools"
tab). See `public/fixtures/README.md` and the "Running test fixtures" section of
`DEVELOPMENT.md`.

## Every fixture is a test

**Every** `*.json` file anywhere under `public/fixtures/` is loaded and replayed
by `spec/lib/engine/game/fixtures_spec.rb`. A broken or non-finished fixture is a
**failing test, not a skipped one.**

Required in the JSON:

- `title` == the canonical engine title (`"1830"`, `"18 Chesapeake"`, …).
- `status` == `"finished"` and `loaded` == `true`.
- every `result` value an integer; every action `id` an integer.
- `game_end_reason` non-null.

If the game didn't reach a natural end, use the "end game" option in the Tools
tab before exporting.

The file must be **single-line minified JSON** — `fixtures_spec.rb` asserts
`@text.lines.size == 1`.

Each fixture is replayed under **both `strict: false` and `strict: true`**; the
engine result must match `result` exactly, bank cash must balance
(`spenders.sum(:cash) == bank_starting_cash`), and total debt
(`[bank, *players].sum(:debt)`) must be `0`.

## Directory name

The containing directory is `meta.fixture_dir_name` — the `FIXTURE_DIR_NAME`
constant if set, otherwise `title.gsub(/[^0-9a-z]/i, '')`: the title with every
non-alphanumeric character removed, case preserved. **Not `g_`-prefixed, not
underscored.**

- `"1830"` → `public/fixtures/1830/`
- `"1846 2p Variant"` → `public/fixtures/18462pVariant/`
- `"1849: Kingdom of the Two Sicilies"` → `public/fixtures/1849KingdomoftheTwoSicilies/`

Check with `Engine.meta_by_title('<title>').fixture_dir_name` in `irb`. (`spec`
resolves the directory back to a game *fuzzily*, so a misnamed directory fails on
the `fixture_dir_name` assertion, not with "not found".)

## Formatting

After exporting or hand-editing a fixture, run **`make fixture_format`** — it
compresses to one line, scrubs player data, and fills `game_end_reason`. For a
temporary readable/diffable copy:
`docker compose exec rack rake fixture_format[<id>,1]`.

Scrubbing replaces player names with `Player N`, `user` with
`{ id: 0, name: 'You' }`, blanks `description`, and drops chat/message actions.
Opt out per fixture with a top-level `"fixture_format"` key:

```json
"fixture_format": { "keep_user": true, "keep_description": true, "chat": "keep" }
```

`"chat"` accepts `"keep"` or `"scrub"`. `"test_last_actions": <n>` opts into a
tail comparison of the last n actions.

## Coverage gate

`spec/lib/engine/fixtures_required_spec.rb` enforces, by `DEV_STAGE`:

- `:prealpha` — no fixture required.
- `:alpha` — at least one fixture whose `game_end_reason` is not
  `manually_ended`.
- `:beta` / `:production` — at least one fixture per reason in the game's
  `GAME_END_CHECK` (or an entry in that spec's `SKIP_BETA_PROD`).

Promoting a game's `DEV_STAGE` can therefore require adding fixtures.

## Running one

```bash
docker compose exec rack rspec spec/lib/engine/game/fixtures_spec.rb -e '<title> <id>'
```

`<id>` is the filename without `.json` (including any `hs_..._` hotseat prefix).
