# frozen_string_literal: true

class Turn < Snabberb::Component
  needs :game_url
  needs :game_id

  def render
    h(:div, [
      h(:a, { href: @game_url }, "Go To Game #{@game_id}"),
    ])
  end
end
