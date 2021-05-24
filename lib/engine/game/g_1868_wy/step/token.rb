# frozen_string_literal: true

require_relative '../../../step/token'
require_relative '../skip_coal_and_oil'

module Engine
  module Game
    module G1868WY
      module Step
        class Token < Engine::Step::Token
          include G1868WY::SkipCoalAndOil
        end
      end
    end
  end
end
