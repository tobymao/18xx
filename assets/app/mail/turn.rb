# frozen_string_literal: true

# This file generates a backtick warning when running tests, but resolving it by adding
# the same warning suppression comment as other files breaks the e-mail notifications.
# See: https://github.com/tobymao/18xx/pull/10382
#      https://github.com/tobymao/18xx/pull/10479
#      https://github.com/tobymao/18xx/pull/10531

class Turn < Snabberb::Component
  needs :game_url
  needs :game_id
  needs :bg_stats_url, default: nil

  def render
    links = [h(:a, { attrs: { href: @game_url } }, "Go To Game #{@game_id}")]
    links << h(:a, { attrs: { href: @bg_stats_url } }, 'Log to BG Stats') if @bg_stats_url
    h(:div, links.map { |link| h(:div, [link]) })
  end
end
