# frozen_string_literal: true

require 'view/game/player'

module View
  module Game
    class Players < Snabberb::Component
      needs :game

      def render
        all_players = @game.player_entities
        active_players = all_players.reject(&:bankrupt)
        bankrupt_players = all_players.select(&:bankrupt)

        active_children = active_players.map { |p| h(Player, player: p, game: @game) }
        active_step = @game.round.active_step
        active_children.unshift(h(Bank, game: @game)) if active_step.respond_to?(:seed_money) && active_step.seed_money

        outer_style = { margin: '1rem 0 1.5rem 0' }

        return h('div.players', { style: outer_style }, active_children.compact) if bankrupt_players.empty?

        bankrupt_cards = bankrupt_players.map { |p| h(:div, { style: { zoom: '0.5' } }, [h(Player, player: p, game: @game)]) }
        bankrupt_col = h(:div, {
                           style: {
                             display: 'flex',
                             flexDirection: 'column',
                             gap: '0.5rem',
                             flexShrink: '0',
                             paddingLeft: '0.5rem',
                           },
                         }, bankrupt_cards)

        h('div.players', { style: outer_style.merge(display: 'flex', alignItems: 'flex-start') },
          [h(:div, { style: { flex: '1' } }, active_children.compact), bankrupt_col])
      end
    end
  end
end
