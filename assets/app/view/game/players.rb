# frozen_string_literal: true

require 'view/game/player'

module View
  module Game
    class Players < Snabberb::Component
      needs :game

      def render
        props = {
          style: { margin: '1rem 0 1.5rem 0' },
        }

        children = @game.players.map { |p| h(Player, player: p, game: @game) }
        children.unshift(h(Bank, game: @game, layout: :card)) if @game.round.active_step.respond_to?(:seed_money)
        h('div.players', props, children)
      end
    end
  end
end
