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
        corporation = @round.current_operator
        ability = ability(company, train: action.train)
        from_depot = action.train.from_depot?
        buy_train_action(action, corporation)

        @round.bought_trains << corporation if from_depot && @round.respond_to?(:bought_trains)

        closes_company = ability.count && (ability.count - 1).zero? && ability.closed_when_used_up

        ability.use! if action.price < action.train.price &&
          ability.discounted_price(action.train, action.train.price) == action.price
        if closes_company && !action.entity.closed?
          action.entity.close!
          @log << "#{company.name} closes"
        end

        pass! unless can_buy_train?(corporation)
      end

      def ability_timing
        %w[%current_step% buying_train owning_corp_or_turn owning_player_or_turn]
      end

      def ability(entity, train: nil)
        return unless entity&.company?

        @game.abilities(entity, :train_discount, time: ability_timing) do |ability|
          return ability if !train || ability.trains.empty? || ability.trains.include?(train.name)
        end

        nil
      end
    end
  end
end
