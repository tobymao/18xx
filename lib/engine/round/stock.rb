# frozen_string_literal: true

require 'engine/action/buy_share'
require 'engine/action/float'
require 'engine/action/sell_share'

module Engine
  module Round
    class Stock < Base
      def initialize(entities, share_pool:, stock_market:)
        super

        @share_pool = share_pool
        @stock_market = stock_market
      end

      def pass
        @current_entity.pass!
      end

      def finished?
        active_entities.all?(&:passed?)
      end

      private

      def _process_action(action)
        @current_entity.unpass!

        case action
        when Action::BuyShare
          @share_pool.buy_share(action.entity, action.share)
        when Action::SellShare
          @share_pool.sell_share(action.entity, action.share)
          @stock_market.move_down(action.corporation)
        when Action::Float
          @stock_market.set_par(action.corporation, action.share_price)
          @share_pool.buy_share(action.entity, action.corporation.shares.first)
        end
      end
    end
  end
end
