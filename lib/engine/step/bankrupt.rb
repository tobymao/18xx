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
        player = @game.acting_for_entity(corp.owner)

        unless @game.can_go_bankrupt?(player, corp)
          buying_power = @game.format_currency(@game.total_emr_buying_power(player, corp))
          price = @game.format_currency(@game.depot.min_depot_price)

          msg = "Cannot go bankrupt. #{corp.name}'s cash plus #{player.name}'s cash and "\
                "sellable shares total #{buying_power}, and the cheapest train in the "\
                "Depot costs #{price}."
          raise GameError, msg
        end

        sell_bankrupt_shares(player, corp)
        @round.recalculate_order if @round.respond_to?(:recalculate_order)
        player.set_cash(0, @game.bank)
        @game.declare_bankrupt(player)
      end

      def sell_bankrupt_shares(player, _corp)
        @log << "-- #{player.name} goes bankrupt and sells remaining shares --"

        player.shares_by_corporation(sorted: true).each do |corporation, _|
          next unless corporation.share_price # if a corporation has not parred

          # Do a potential repeated sell of bundles. This is important for NdM in 18MEX
          # which might have 5% bundle(s) besides the 10%+ bundles.
          # Most other titles this will just sell one, the largest, bundle.
          while (bundle = @game.sellable_bundles(player, corporation).max_by(&:price))
            @game.sell_shares_and_change_price(bundle)
          end
        end
      end
    end
  end
end
