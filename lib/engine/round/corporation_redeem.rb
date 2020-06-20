# frozen_string_literal: true

module Engine
  module Round
    module CorporationRedeem
      def process_buy_shares(action)
        @game.share_pool.buy_shares(@current_entity, action.bundle)
      end
    end
  end
end
