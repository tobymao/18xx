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

        # Can only sell as much as you need to afford the train
        selling_minimum_shares?(bundle) unless @game.class::EBUY_SELL_MORE_THAN_NEEDED
      end

      def selling_minimum_shares?(bundle)
        seller = bundle.owner
        total_cash = bundle.price + available_cash(seller)
        total_cash < needed_cash(seller) + bundle.price_per_share
      end

      def sellable_bundle?(bundle)
        seller = bundle.owner
        # Can't sell president's share
        return false unless bundle.can_dump?(seller)

        # Can't oversaturate the market
        return false unless @game.share_pool.fit_in_bank?(bundle)

        corporation = bundle.corporation
        return true if corporation == seller

        # Can't swap presidency
        return false if president_swap_disallowed?(corporation, seller) &&
          causes_president_swap?(corporation, bundle)

        # Otherwise we're good
        true
      end

      def president_swap_disallowed?(corporation, seller)
        corporation.president?(seller) &&
          (!@game.class::EBUY_PRES_SWAP || corporation == current_entity)
      end

      def causes_president_swap?(corporation, bundle)
        seller = bundle.owner
        share_holders = corporation.player_share_holders
        remaining = share_holders[seller] - bundle.percent
        next_highest = share_holders.reject { |k, _| k == seller }.values.max || 0
        remaining < next_highest
      end

      def issuable_shares
        []
      end
    end
  end
end
