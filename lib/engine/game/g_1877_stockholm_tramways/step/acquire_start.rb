# frozen_string_literal: true

require_relative 'acquire'

module Engine
  module Game
    module G1877StockholmTramways
      module Step
        class AcquireStart < G1877StockholmTramways::Step::Acquire
          def mergeable(corporation)
            super.select { |other| @game.round.entities.find_index(corporation) < @game.round.entities.find_index(other) }
          end
        end
      end
    end
  end
end
