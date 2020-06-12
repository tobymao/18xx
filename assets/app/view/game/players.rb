# frozen_string_literal: true

require 'view/game/player'

module View
  module Game
    class Players < Snabberb::Component
      needs :game

      def render
        h('div.player', @game.players.map { |p| h(Player, player: p, game: @game) })
      end
    end
  end
end
