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

            any_twos_upcoming = @game.depot.upcoming.any? { |t| t.name == "2" }
            any_threes_upcoming = @game.depot.upcoming.any? { |t| t.name == "3" }
            depot_three_available = trains_to_buy.any? {|t| t.name == "3" && t.owner == @game.depot }

            if !any_twos_upcoming && any_threes_upcoming && !depot_three_available
              trains_to_buy << @game.depot.upcoming.select { |t| t.name == "3" }.first
            end

            if @game.depot.upcoming.any? { |t| t.name == "2+" }
              trains_to_buy.reject! { |t| t.name == "3+" }
            end

            if @game.depot.upcoming.any? { |t| t.name == "1+" }
              trains_to_buy.reject! { |t| t.name == "2+" }
            end

            return trains_to_buy if @game.can_cross_buy?

            trains_to_buy.select(&:from_depot?)
          end
        end
      end
    end
  end
end
