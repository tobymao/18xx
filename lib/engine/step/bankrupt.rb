# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Bankrupt < Base
      ACTIONS = %w[bankrupt].freeze

      def actions(entity)
        return [] if entity != current_entity

        ACTIONS
      end

      def description
        'Bankrupt'
      end

      def blocks?
        false
      end

      def process_bankrupt(action)
        corp = action.entity
        player = corp.owner

        unless @game.can_go_bankrupt?(player, corp)
          buying_power = @game.format_currency(@game.total_emr_buying_power(player, corp))
          price = @game.format_currency(@game.depot.min_depot_price)

          msg = "Cannot go bankrupt. #{corp.name}'s cash plus #{player.name}'s cash and "\
                "sellable shares total #{buying_power}, and the cheapest train in the "\
                "Depot costs #{price}."
          @game.game_error(msg)
        end

        @log << "-- #{player.name} goes bankrupt and sells remaining shares --"

        player.shares_by_corporation.each do |corporation, _|
          next unless corporation.share_price # if a corporation has not parred

          # Do a potential repeated sell of bundles. This is important for NdM in 18MEX
          # which might have 5% bundle(s) besides the 10%+ bundles.
          # Most other titles this will just sell one, the largest, bundle.
          while (bundle = @game.sellable_bundles(player, corporation).max_by(&:price))
            @game.sell_shares_and_change_price(bundle)
          end
        end
        @round.recalculate_order

        player.spend(player.cash, @game.bank) if player.cash.positive?

        @game.declare_bankrupt(player)
      end
    end
  end
end
