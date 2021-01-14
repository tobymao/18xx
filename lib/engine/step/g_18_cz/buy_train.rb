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
            return medium_trains if entity.trains.none? do |item|
                                      (item.name =~ @game.medium_train_regex)
                                    end && room_for_only_one?(entity)

            return default_trains + medium_trains
          end

          large_trains = trains.select { |item| (item[:name] =~ @game.large_train_regex) }

          large_trains if entity.trains.none? do |item|
                            (item.name =~ @game.large_train_regex)
                          end && room_for_only_one?(entity)
          default_trains + medium_trains + large_trains
        end

        def room_for_only_one?(entity)
          @game.phase.train_limit(entity) - entity.trains.size == 1
        end
      end
    end
  end
end
