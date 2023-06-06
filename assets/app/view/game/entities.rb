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
        players = @game.player_entities
        if (i = players.map(&:name).rindex(@user&.dig(:name)))
          players = players.rotate(i)
        end

        bankrupt_players, players = players.partition(&:bankrupt)

        player_owned, bank_owned = (@game.corporations + @game.minors)
          .reject(&:closed?)
          .partition(&:owner)
        player_owned = @game.player_sort(player_owned)
        bank_owned = @game.bank_sort(bank_owned)

        children = players.map do |p|
          corps = player_owned[p]&.map { |c| h(Corporation, corporation: c) }

          h(:div, [
            h(Player, player: p, game: @game),
            *corps,
          ])
        end

        extra_bank = []
        if @game.respond_to?(:unstarted_corporation_summary)
          others = @game.unstarted_corporation_summary.last
          extra_bank.concat(others.map { |c| h(Corporation, corporation: c) })
        else
          extra_bank.concat(bank_owned.map { |c| h(Corporation, corporation: c) })
        end
        children << h(:div, [
          h(Bank, game: @game),
          h(GameInfo, game: @game, layout: 'upcoming_trains'),
          *@game.unowned_purchasable_companies(@current_entity).map { |company| h(Company, company: company) },
          *@game.receivership_corporations.map { |c| h(Corporation, corporation: c) },
          *extra_bank,
        ].compact)

        children.concat(bankrupt_players.map { |p| h(:div, [h(Player, player: p, game: @game)]) })

        h('div#entities', div_props, children)
      end
    end
  end
end
