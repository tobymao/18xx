# frozen_string_literal: true

module Engine
  module Round
    module CorporationIssue
      def process_sell_shares(action)
        return super if action.entity.player?

        @game.share_pool.sell_shares(action.bundle)
      end
    end
  end
end
