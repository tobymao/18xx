# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G18CZ
      class BuyTrain < BuyTrain
        def buyable_train_variants(train, entity)
          trains = super

          return [] unless trains.any?

          default_trains = trains.select { |item| (item[:name] =~ @game.small_train_regex) }
          return default_trains if entity.type == :small

          medium_trains = trains.select { |item| (item[:name] =~ @game.medium_train_regex) }
          if entity.type == :medium
            if entity.trains.none? { |item| (item.name =~ @game.medium_train_regex) } && room_for_only_one?(entity)
              return medium_trains
            else
              return default_trains + medium_trains
            end
          end

          # large corporation left
          large_trains = trains.select { |item| (item[:name] =~ @game.large_train_regex) }

          if entity.trains.none? { |item| (item.name =~ @game.large_train_regex) } && room_for_only_one?(entity)
            large_trains
          else
            default_trains + medium_trains + large_trains
          end
        end

        def room_for_only_one?(entity)
          @game.phase.train_limit(entity) - entity.trains.size == 1
        end
      end
    end
  end
end
