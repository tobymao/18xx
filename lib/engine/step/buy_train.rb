# frozen_string_literal: true

require_relative 'base'
require_relative 'train'

module Engine
  module Step
    class BuyTrain < Base
      include Train

      def actions(entity)
        # 1846 and a few others minors can't buy trains
        return [] if entity.minor?

        # TODO: This needs to check it actually needs to sell shares.
        return ['sell_shares'] if entity == current_entity.owner

        return [] if entity != current_entity
        # TODO: Not sure this is right
        return %w[sell_shares buy_train] if must_buy_train?(entity)
        return %w[buy_train pass] if can_buy_train?(entity)

        []
      end

      def description
        'Buy Trains'
      end

      def pass_description
        @acted ? 'Done (Trains)' : 'Skip (Trains)'
      end

      def pass!
        @last_share_sold_price = nil
        @last_share_issued_price = nil
        super
      end

      def process_buy_train(action)
        buy_train_action(action)
        pass! unless can_buy_train?(action.entity)
      end
    end
  end
end
