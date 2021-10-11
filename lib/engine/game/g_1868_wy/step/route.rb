# frozen_string_literal: true

require_relative '../../../step/route'
require_relative '../skip_coal_and_oil'

module Engine
  module Game
    module G1868WY
      module Step
        class Route < Engine::Step::Route
          include G1868WY::SkipCoalAndOil
        end
      end
    end
  end
end
