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
      end

      def can_sell?(_entity, bundle)
        return false unless sellable_bundle?(bundle)

        # Can only sell as much as you need to afford the train
        player = bundle.owner
        unless @game.class::EBUY_SELL_MORE_THAN_NEEDED
          total_cash = bundle.price + available_cash(player)
          return false if total_cash >= needed_cash(player) + bundle.price_per_share
        end

        true
      end

      def sellable_bundle?(bundle)
        player = bundle.owner
        # Can't sell president's share
        return false unless bundle.can_dump?(player)

        # Can't oversaturate the market
        return false unless @game.share_pool.fit_in_bank?(bundle)

        # Can't swap presidency
        corporation = bundle.corporation
        if corporation.president?(player) &&
            (!@game.class::EBUY_PRES_SWAP || corporation == current_entity)
          share_holders = corporation.player_share_holders
          remaining = share_holders[player] - bundle.percent
          next_highest = share_holders.reject { |k, _| k == player }.values.max || 0
          return false if remaining < next_highest
        end

        # Otherwise we're good
        true
      end

      def issuable_shares
        []
      end
    end
  end
end
