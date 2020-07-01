# frozen_string_literal: true

require 'view/game/player'

module View
  module Game
    class Entities < Snabberb::Component
      needs :game
      needs :user, default: nil, store: true

      def render
        div_props = {
          style: {
            display: 'grid',
            grid: 'auto / repeat(auto-fill, minmax(17rem, 1fr))',
            gap: '3rem 1.2rem',
          },
        }
        column_props = {
          style: {
            display: 'grid',
            alignContent: 'start',
            justifyContent: 'stretch',
          },
        }

        players = @game.players
        if (i = players.map(&:name).rindex(@user&.dig(:name)))
          players = players.rotate(i)
        end

        player_owned, bank_owned = (@game.corporations + @game.minors).partition(&:owner)

        children = players.map do |p|
          corps = player_owned.select { |c| c.owner == p }.sort_by(&:name).map { |c| h(Corporation, corporation: c) }

          h(:div, column_props, [
            h(Player, player: p, game: @game),
            *corps,
          ])
        end

        children << h(:div, column_props, bank_owned.map { |c| h(Corporation, corporation: c) })

        h('div#entities', div_props, children)
      end
    end
  end
end
