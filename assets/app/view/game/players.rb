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

        children = @game.player_entities.map { |p| h(Player, player: p, game: @game) }
        active_step = @game.round.active_step
        children.unshift(h(Bank, game: @game)) if active_step.respond_to?(:seed_money) && active_step.seed_money
        h('div.players', props, children.compact)
      end
    end
  end
end
