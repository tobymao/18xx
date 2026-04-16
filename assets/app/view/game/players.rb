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

        all_players = @game.player_entities
        active_players = all_players.reject(&:bankrupt)
        bankrupt_players = all_players.select(&:bankrupt)

        children = active_players.map { |p| h(Player, player: p, game: @game) }

        unless bankrupt_players.empty?
          bankrupt_col_props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }
          bankrupt_children = bankrupt_players.map { |p| h(Player, player: p, game: @game, display: 'block') }
          children << h(:div, bankrupt_col_props, bankrupt_children)
        end

        active_step = @game.round.active_step
        children.unshift(h(Bank, game: @game)) if active_step.respond_to?(:seed_money) && active_step.seed_money
        h('div.players', props, children.compact)
      end
    end
  end
end
