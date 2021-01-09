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

        # Need to keep some attributes in case ability is removed when used
        count_after_use = ability.count - 1
        closed_when_used_up = ability.closed_when_used_up

        ability.use! if action.price < action.train.price &&
          ability.discounted_price(action.train, action.train.price) == action.price
        if count_after_use.zero? && closed_when_used_up
          action.entity.close!
          @log << "#{company.name} closes due to use of discount to buy train"
        end

        pass! unless can_buy_train?(corporation)
      end

      def ability(entity)
        return unless entity&.company?

        @game.abilities(entity, :train_discount, time: 'buying_train')
      end
    end
  end
end
