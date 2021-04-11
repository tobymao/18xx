# frozen_string_literal: true

module Engine
  module G18ZOO
    module Ability
      class IncreaseDistanceForTrain < Engine::Ability::Base
        attr_reader :train, :distance

        def setup(train:, distance:)
          @train = train
          @distance = distance
        end
      end
    end
  end
end
