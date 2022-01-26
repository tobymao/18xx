# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1866
      module Round
        class Stock < Engine::Round::Stock
          attr_accessor :player_passed

          def setup
            @player_passed = {}

            super
          end
        end
      end
    end
  end
end
