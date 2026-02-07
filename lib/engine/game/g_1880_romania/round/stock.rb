# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1880Romania
      module Round
        class Stock < Engine::Round::Stock
          def show_auto?
            true
          end
        end
      end
    end
  end
end
