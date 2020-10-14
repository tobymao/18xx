# frozen_string_literal: true

require 'view/game/bank'
require 'view/game/player'

module View
  module Game
    class Entities < Snabberb::Component
      needs :game
      needs :user

      def render
        div_props = {
          style: {
            display: 'grid',
            grid: 'auto / repeat(auto-fill, minmax(17rem, 1fr))',
            gap: '3rem 1.2rem',
          },
        }

        players = @game.players
        if (i = players.map(&:name).rindex(@user&.dig(:name)))
          players = players.rotate(i)
        end

        player_owned, bank_owned = (@game.corporations + @game.minors).sort_by(&:name).partition(&:owner)
        player_owned = player_owned.group_by(&:owner)

        children = players.map do |p|
          corps = player_owned[p]&.map { |c| h(Corporation, corporation: c) }

          h(:div, [
            h(Player, player: p, game: @game),
            *corps,
          ])
        end

        children << h(:div, [
          h(Bank, game: @game, layout: :card),
          *@game.corporations.select(&:receivership?).map { |c| h(Corporation, corporation: c) },
          *bank_owned.map { |c| h(Corporation, corporation: c) },
        ].compact)

        h('div#entities', div_props, children)
      end
    end
  end
end
