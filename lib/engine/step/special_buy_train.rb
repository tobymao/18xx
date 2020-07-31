# frozen_string_literal: true

require_relative 'base'
require_relative 'train'

module Engine
  module Step
    class SpecialBuyTrain < Base
      include Train

      ACTIONS = %w[buy_train].freeze

      def actions(entity)
        return [] unless ability(entity)

        ACTIONS
      end

      def blocks?
        false
      end

      def process_buy_train(action)
        corporation = action.entity.owner
        from_depot = action.train.from_depot?
        buy_train_action(action, corporation)

        @round.bought_trains << corporation if from_depot

        ability = ability(action.entity)
        ability.use! if action.price < action.train.price &&
          ability.discounted_price(action.train, action.train.price) == action.price
        begin
          action.entity.close!
          @log << "#{action.entity.name} closes due to use of discount to buy train"
        end if ability.count.zero?

        pass! unless can_buy_train?(corporation)
      end

      def ability(entity)
        return unless entity.company?

        entity.abilities(:train_discount, 'train')
      end
    end
  end
end
