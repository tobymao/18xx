# frozen_string_literal: true

# This file generates a backtick warning when running tests, but resolving it by adding
# the same warning suppression comment as other files breaks the e-mail notifications.
# See: https://github.com/tobymao/18xx/pull/10382
#      https://github.com/tobymao/18xx/pull/10479
#      https://github.com/tobymao/18xx/pull/10531

class Turn < Snabberb::Component
  needs :game_url
  needs :game_id

  def render
    h(:div, [
      h(:a, { attrs: { href: @game_url } }, "Go To Game #{@game_id}"),
    ])
  end
end
