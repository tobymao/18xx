Fixes #[PUT_ISSUE_NUMBER_HERE]

<!--

Your PR title should start with a tag showing the affected 18xx title or titles,
e.g., "[1889] use fancy logos".

Please minimize the amount of changes to shared `lib/engine` code, if
possible. If you are changing any shared code there, please include "[core]" at
the start of your PR title.

If your changes affect the developer/maintainer experience but are not end-user
facing, please inclue a "[dev]" tag.

If you are implementing a new game, please break up the changes into multiple
PRs for ease of review.

-->

## Before clicking "Create"

- [ ] Branch is derived from the latest `master`
- [ ] Add the `pins` or `archive_alpha_games` label if this change will break existing games
- [ ] Code passes linter with `docker compose exec rack rubocop -a`
- [ ] Tests pass cleanly with `docker compose exec rack rake`

## Implementation Notes

### Explanation of Change

### Screenshots

### Any Assumptions / Hacks
