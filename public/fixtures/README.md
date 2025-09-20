Fixtures are JSON representations of played games. When in a game, on the
"Tools" tab, the JSON data for the game can be copied or downloaded.

## Tests

Also see "Running test fixtures" in `DEVELOPMENT.md`.

### Automatic tests

Any game added here is automatically added to the tests in
`spec/lib/engine/game/fixtures_spec.rb`. These tests verify that a game for the
given title can be completed. Fixtures can be added to test specific action
flows. The fixture can be renamed to reflect what functionality it is testing,
or this can be documented in the commit message that adds the fixture.

The automatic tests expect the following to be in the game JSON:

- `"status"` key with value `"finished"`
- `"loaded"` key with value `true`
- `"result"` key with data matching the result when the game is played out by the engine

Since the game is expected to be over, be sure to use the "end game" option in
the "Tools" tab if your test fixture does not play out to an actual endgame.

### Testing and debugging game state

It is tedious to set up a valid game state by writing Ruby code. Tests can be
written which instead load fixtures from files at any arbitrary point in the
game, and then Ruby code can be used to inspect or assert arbitrary things about
the game state.

This is particularly useful when you want to assert that something cannot happen
at a given state, as that sort of behavior cannot be picked up by the automatic
tests described above.

Adding `require 'pry-byebug'` and `binding.pry` to one of these tests is an easy
way to debug the game state in the Ruby server world instead of debugging in the
compiled JavaScript in the web browser.

Example: [tests for 18Chesapeake][0] that inspect game state before and after
particular actions, or process alternate actions not found in the fixture JSON

[0]: https://github.com/tobymao/18xx/blob/8364e720d5f0ecd2d64be3eb3638461a10158bbd/spec/game_state_spec.rb#L32-L85

### `assets_spec.rb`

Fixtures can also be referenced in `spec/assets_spec.rb`. These UI tests allow
for assertions to be made about text that is expected to be found in the DOM.

### Formatting and Diffing

`fixtures_spec.rb` also enforces certain formatting for each fixture file.

The fixtures in this directory are formatted with `make fixture_format`
which, among other things, removes all whitespace and compresses each of them to
one line of text. This keeps diff sizes for PRs down but makes it very difficult
to tell what's changed when a fixture is updated. With `.gitattributes` and a
custom diff tool, the changes can be more apparent when working locally.

To use [jq](https://jqlang.org/), install it with `brew install jq` and then
copy this block either into your global git config (`~/.gitconfig`), or into
your local clone of this repo's `.git/config`:

```
[diff "json"]
	textconv = bash -c 'jq . \"$0\" -'
```

Other tools than `jq` can be used, just swap out the command used in your
`textconv` configuration.
