# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module EmergencyMoney
      def process_sell_shares(action)
        unless can_sell?(action.entity, action.bundle)
          @game.game_error("Cannot sell shares of #{action.bundle.corporation.name}")
        end

        @game.sell_shares_and_change_price(action.bundle)

        @round.recalculate_order if @round.respond_to?(:recalculate_order)
      end

      def can_sell?(_entity, bundle)
        return false unless sellable_bundle?(bundle)
        return true if @game.class::EBUY_SELL_MORE_THAN_NEEDED

        selling_minimum_shares?(bundle)
      end

      def selling_minimum_shares?(bundle)
        seller = bundle.owner
        total_cash = bundle.price + available_cash(seller)
        total_cash < needed_cash(seller) + bundle.price_per_share
      end

      def sellable_bundle?(bundle)
        seller = bundle.owner
        return false unless bundle.can_dump?(seller)

        # Can't oversaturate the market
        return false unless @game.share_pool.fit_in_bank?(bundle)

        corporation = bundle.corporation
        return true unless corporation.president?(seller)
        return true unless president_swap_concern?(corporation)

        !causes_president_swap?(corporation, bundle)
      end

      def president_swap_concern?(corporation)
        !@game.class::EBUY_PRES_SWAP || corporation == current_entity
      end

      def causes_president_swap?(corporation, bundle)
        seller = bundle.owner
        share_holders = corporation.player_share_holders
        remaining = share_holders[seller] - bundle.percent
        next_highest = share_holders.reject { |k, _| k == seller }.values.max || 0
        remaining < next_highest
      end

      def issuable_shares(entity)
        return [] unless entity.corporation?

        @game.emergency_issuable_bundles(entity)
      end
    end
  end
end
