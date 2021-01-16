# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1824
      class BuyTrain < BuyTrain
        def actions(entity)
          # TODO: This needs to check it actually needs to sell shares.
          return ['sell_shares'] if entity == current_entity.owner

          return [] if entity != current_entity
          # TODO: Not sure this is right
          return %w[sell_shares buy_train] if president_may_contribute?(entity)

          return %w[buy_train pass] if can_buy_train?(entity)

          []
        end

        def process_buy_train(action)
          entity ||= action.entity
          train = action.train

          if entity&.corporation? && !@game.g_train?(train) && @game.coal_railway?(entity)
            raise GameError, 'Coal railways can only own g-trains'
          end

          @game.two_train_bought = true if train.name == '2'

          super
        end

        def buyable_trains(entity)
          trains = super
          is_coal_company = @game.coal_railway?(entity)

          # Coal railways may only buy g-trains, other corporations may buy any
          trains.reject! { |t| is_coal_company && !@game.g_train?(t) }

          # Cannot buy g-trains until first 2 train has been bought
          trains.reject! { |t| @game.g_train?(t) && !@game.two_train_bought }

          trains.select!(&:from_depot?) unless @game.phase.status.include?('can_buy_trains')

          trains
        end
      end
    end
  end
end
