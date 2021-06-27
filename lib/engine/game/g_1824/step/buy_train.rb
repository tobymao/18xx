# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1824
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_entity_buy_train?
            true
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
end
