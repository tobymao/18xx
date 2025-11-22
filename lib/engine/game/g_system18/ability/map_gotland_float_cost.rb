# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module GSystem18
      module Gotland
        class FloatCost < Engine::Ability::Base
          attr_accessor :float_cost

          def setup(float_cost:)
            @float_cost = float_cost
          end
        end
      end
    end
  end
end
