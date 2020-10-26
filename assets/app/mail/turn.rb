# frozen_string_literal: true

require_relative '../view/log.rb'
require_relative '../view/game/players.rb'
require_relative '../view/game/spreadsheet.rb'

class Turn < Snabberb::Component
  needs :game_data
  needs :game_url
  needs :game, store: true, default: nil

  def render
    @game = Engine::GAMES_BY_TITLE[@game_data['title']].new(
      @game_data['players'].map { |p| [p['id'], p['name']] }.to_h,
      id: @game_data['id'],
      actions: @game_data['actions'],
    )

    store(:game, @game, skip: true)

    h(:div, [
      render_link,
      h(View::Log, log: @game.log.last(20)),
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
