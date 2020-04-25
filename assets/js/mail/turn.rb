# frozen_string_literal: true

require 'snabberb'
require '../view/log.rb'
require '../view/players.rb'
require_tree 'engine/game'

class Turn < Snabberb::Component
  needs :game_data
  needs :game_url

  def render
    @game = Engine::Game::G1889.new(
      @game_data['players'].map { |p| p['name'] },
      actions: @game_data['actions'],
    )

    h(:div, [
      render_link,
      h(View::Log, log: @game.log.last(20).reverse),
      h(View::Players, game: @game),
    ])
  end

  def render_link
    props = {
      attrs: { href: @game_url },
    }

    h(:a, props, "Go To Game #{@game_data[:id]}")
  end
end
