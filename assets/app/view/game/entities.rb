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

        bankrupt_players, players = players.partition(&:bankrupt)

        player_owned, bank_owned = (@game.corporations + @game.minors)
          .reject(&:closed?)
          .partition(&:owner)
        player_owned = player_owned.sort_by(&:name).group_by(&:owner)
        bank_owned = @game.bank_sort(bank_owned)

        children = players.map do |p|
          corps = player_owned[p]&.map { |c| h(Corporation, corporation: c) }

          h(:div, [
            h(Player, player: p, game: @game),
            *corps,
          ])
        end

        extra_bank = []
        unless @game.respond_to?(:unstarted_corporation_summary)
          extra_bank.concat(bank_owned.map { |c| h(Corporation, corporation: c) })
        end
        children << h(:div, [
          h(Bank, game: @game),
          h(GameInfo, game: @game, layout: 'upcoming_trains'),
          *@game.corporations.select(&:receivership?).map { |c| h(Corporation, corporation: c) },
          *extra_bank,
        ].compact)

        children = children.concat(bankrupt_players.map { |p| h(:div, [h(Player, player: p, game: @game)]) })

        h('div#entities', div_props, children)
      end
    end
  end
end
