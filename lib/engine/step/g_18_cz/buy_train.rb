# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G18CZ
      class BuyTrain < BuyTrain
        def buyable_train_variants(train, entity)
          trains = super

          return [] if trains.empty?

          default_trains = trains.select { |item| @game.train_of_size?(item, :small) }
          return default_trains if entity.type == :small

          medium_trains = trains.select { |item| @game.train_of_size?(item, :medium) }
          if entity.type == :medium
            return medium_trains if entity.trains.none? do |item|
              @game.train_of_size?(item, :medium)
            end && room_for_only_one?(entity)

            return default_trains.concat(medium_trains)
          end

          large_trains = trains.select { |item| @game.train_of_size?(item, :large) }

          large_trains if entity.trains.none? do |item|
            @game.train_of_size?(item, :large)
          end && room_for_only_one?(entity)
          default_trains.concat(medium_trains).concat(large_trains)
        end

        def room_for_only_one?(entity)
          @game.phase.train_limit(entity) - entity.trains.size == 1
        end
      end
    end
  end
end
