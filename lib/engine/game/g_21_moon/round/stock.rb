# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G21Moon
      module Round
        class Stock < Engine::Round::Stock
          def finish_round; end
        end
      end
    end
  end
end
