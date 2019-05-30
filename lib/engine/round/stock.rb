# frozen_string_literal: true

require 'engine/action/buy_share'
require 'engine/action/float'
require 'engine/action/sell_share'

module Engine
  module Round
    class Stock < Base
      attr_reader :share_pool, :stock_market

      def finished?
        active_entities.all?(&:passed?)
      end

      private

      def init_round(opts)
        @share_pool = opts[:share_pool]
        @stock_market = opts[:stock_market]
      end

      def _process_action(action)
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
