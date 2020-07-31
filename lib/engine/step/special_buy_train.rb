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
        actual_buyer = action.entity.owner

        buy_train_action(action, actual_buyer)

        @round.trains_bought << {
          entity: actual_buyer,
        } if action.train.from_depot?

        ability = ability(action.entity)
        ability.use! if action.price < action.train.price &&
          ability.discounted_price(action.train, action.train.price) == action.price
        action.entity.close! if ability.count.zero?

        pass! unless can_buy_train?(actual_buyer)
      end

      def ability(entity)
        return unless entity.company?

        entity.abilities(:train_discount, 'train')
      end
    end
  end
end
