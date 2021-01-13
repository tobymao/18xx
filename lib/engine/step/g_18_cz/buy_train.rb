# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G18CZ
      class BuyTrain < BuyTrain

        def buyable_train_variants(train, entity)
          trains = super
          return [] unless trains.any?

          return trains.select { |item| !!(item[:name] =~ /^[2-5][a-j]$/) } if entity.type == :small
          return trains.select { |item| !!(item[:name] =~ /^[2-5]\+[2-5][a-j]$/) } if entity.type == :medium
          return trains.select { |item| !!(item[:name] =~ /^[3-8]E[a-j]?$/) } if entity.type == :large
        end
      end
    end
  end
end
