# frozen_string_literal: true

require_tree 'engine'
require_relative '../view/game/game_log'
require_relative '../view/game/players'
require_relative '../view/game/spreadsheet'

class Turn < Snabberb::Component
  needs :game_data, store: true
  needs :game_url
  needs :game, store: true, default: nil
  needs :hide_logo, store: true, default: true

  def render
    @game = Engine::Game.load(@game_data)

    store(:game, @game, skip: true)
    store(:hide_logo, @hide_logo, skip: true)

    h(:div, [
      render_link,
      h(View::Game::GameLog, limit: 10),
      h(View::Game::Players, game: @game),
      h(View::Game::Spreadsheet, game: @game),
    ])
  end

  def render_link
    props = {
      attrs: { href: @game_url },
    }

    h(:a, props, "Go To Game #{@game_data[:id]}")
  end
end
