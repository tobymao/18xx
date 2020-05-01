# frozen_string_literal: true

require 'view/player'

module View
  class Players < Snabberb::Component
    needs :game

    def render
      props = {
         style: { margin: '1rem 0 1.5rem 0' }
      }

      h(:div, props, @game.players.map { |p| h(Player, player: p, game: @game) })
    end
  end
end
