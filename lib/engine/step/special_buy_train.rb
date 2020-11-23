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
        company = action.entity
        corporation = company.owner
        ability = ability(company)
        from_depot = action.train.from_depot?
        buy_train_action(action, corporation)

        @round.bought_trains << corporation if from_depot && @round.respond_to?(:bought_trains)

        ability.use! if action.price < action.train.price &&
          ability.discounted_price(action.train, action.train.price) == action.price
        begin
          action.entity.close!
          @log << "#{company.name} closes due to use of discount to buy train"
        end if ability.count.zero?

        pass! unless can_buy_train?(corporation)
      end

      def ability(entity)
        return unless entity.company?

        entity.abilities(:train_discount, time: 'train')
      end
    end
  end
end
