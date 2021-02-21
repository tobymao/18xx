# frozen_string_literal: true

require_relative '../view/game/game_log'
require_relative '../view/game/players'
require_relative '../view/game/spreadsheet'
require_relative '../game_class_loader'

class Turn < Snabberb::Component
  include GameClassLoader

  needs :game_data, store: true
  needs :game_url
  needs :game, store: true, default: nil
  needs :hide_logo, store: true, default: true

  def render
    game_meta = Engine::GAME_META_BY_TITLE[@game_data['title']]
    require_tree "engine/game/#{game_meta.fs_name}"

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
