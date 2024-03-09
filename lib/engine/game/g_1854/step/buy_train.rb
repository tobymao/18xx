# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1854
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_entity_buy_train?(entity)
            return true if entity.corporation? || entity.minor?

            super
          end

          def buyable_trains(entity)
            # allow purchase of 3 train when 2s are all sold
            trains_to_buy = super

            trains_to_buy.reject! { |t| t.name == '3+' } if @game.depot.upcoming.any? { |t| t.name == '2+' }

            trains_to_buy.reject! { |t| t.name == '2+' } if @game.depot.upcoming.any? { |t| t.name == '1+' }

            return trains_to_buy if @game.can_cross_buy?

            trains_to_buy.select(&:from_depot?)
          end
        end
      end
    end
  end
end
