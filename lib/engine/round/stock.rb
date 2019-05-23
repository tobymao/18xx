# frozen_string_literal: true

module Engine
  module Round
    class Stock < Base
      def finished?
        @active_entities.all?(&:passed?)
      end

      private

      def init_round(opts)
        @share_pool = opts[:share_pool]
        @stock_market = opts[:stock_market]
      end

      def _process_action(action)
        case action
        when BuyShare
          @share_pool.buy_share(action.entity, action.share)
        when SellShare
          @share_pool.sell_share(action.entity, action.share)
          @stock_market.move_down(action.corporation)
        when Float
          @share_pool.buy_share(action.entity, action.share)
          @stock_market.set_par(action.corporation)
        end
      end
    end
  end
end
