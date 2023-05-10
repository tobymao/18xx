# frozen_string_literal: true

require_relative 'base'
require_relative 'train'

module Engine
  module Step
    class BuyTrain < Base
      include Train

      def actions(entity)
        # 1846 and a few others minors can't buy trains
        return [] unless can_entity_buy_train?(entity)

        # TODO: This needs to check it actually needs to sell shares.
        return ['sell_shares'] if entity == current_entity&.owner && can_ebuy_sell_shares?(current_entity)

        return [] if entity != current_entity
        # TODO: Not sure this is right
        return %w[sell_shares buy_train] if president_may_contribute?(entity)
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

      def check_spend(action)
        return unless action.train.owned_by_corporation?

        min, max = spend_minmax(action.entity, action.train)
        return if (min..max).cover?(action.price)

        if max.zero? && !@game.class::EBUY_OTHER_VALUE
          raise GameError, "#{action.entity.name} may not buy a train from "\
                           'another corporation.'
        else
          raise GameError, "#{action.entity.name} may not spend "\
                           "#{@game.format_currency(action.price)} on "\
                           "#{action.train.owner.name}'s #{action.train.name} "\
                           'train; may only spend between '\
                           "#{@game.format_currency(min)} and "\
                           "#{@game.format_currency(max)}."
        end
      end

      def process_buy_train(action)
        check_spend(action)
        buy_train_action(action)
        pass! if !can_buy_train?(action.entity) && pass_if_cannot_buy_train?(action.entity)
      end

      def swap_sell(_player, _corporation, _bundle, _pool_share); end
    end
  end
end
